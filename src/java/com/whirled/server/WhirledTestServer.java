//
// $Id$

package com.whirled.server;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.Reader;

import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.logging.Level;

import org.apache.mina.common.IoAcceptor;

import com.google.common.collect.Lists;
import com.google.common.collect.Sets;
import com.google.inject.Guice;
import com.google.inject.Inject;
import com.google.inject.Injector;

import com.samskivert.util.CollectionUtil;
import com.threerings.util.Name;
import com.samskivert.util.StringUtil;

import com.threerings.presents.data.ClientObject;
import com.threerings.presents.data.InvocationCodes;
import com.threerings.presents.dobj.RootDObjectManager;
import com.threerings.presents.net.AuthRequest;
import com.threerings.presents.server.ClientFactory;
import com.threerings.presents.server.ClientManager;
import com.threerings.presents.server.ClientResolver;
import com.threerings.presents.server.InvocationManager;
import com.threerings.presents.server.PresentsClient;
import com.threerings.presents.server.ShutdownManager;

import com.threerings.crowd.data.BodyObject;
import com.threerings.crowd.data.PlaceConfig;
import com.threerings.crowd.server.CrowdServer;
import com.threerings.crowd.server.PlaceManagerDelegate;

import com.threerings.bureau.data.BureauCredentials;
import com.threerings.bureau.server.BureauRegistry;

import com.threerings.parlor.data.Parameter;
import com.threerings.parlor.game.server.GameManager;
import com.threerings.parlor.server.ParlorManager;
import com.threerings.parlor.server.ParlorSender;

import com.whirled.bureau.data.BureauTypes;
import com.whirled.game.data.GameDefinition;
import com.whirled.game.data.TableMatchConfig;
import com.whirled.game.data.TestGameDefinition;
import com.whirled.game.data.WhirledGameConfig;
import com.whirled.game.server.DictionaryManager;
import com.whirled.game.server.GameCookieManager;
import com.whirled.game.server.PrefsCookieManager;
import com.whirled.game.server.TestDispatcher;
import com.whirled.game.server.TestProvider;
import com.whirled.game.server.WhirledGameManager;
import com.whirled.game.xml.TestGameParser;
import com.whirled.game.xml.WhirledGameParser;

import static com.whirled.Log.log;

/**
 * Handles setting up the Whirled standalone test server.
 */
public class WhirledTestServer extends CrowdServer
    implements TestProvider, BureauRegistry.CommandGenerator, ShutdownManager.Shutdowner
{
    /** Configures dependencies needed by the Whirled test services. */
    public static class Module extends CrowdServer.Module
    {
        @Override protected void configure () {
            super.configure();
            bind(GameCookieManager.class).to(PrefsCookieManager.class);
        }
    }

    /**
     * The main entry point for the test server.
     */
    public static void main (String[] args)
    {
        Injector injector = Guice.createInjector(new Module());
        WhirledTestServer server = injector.getInstance(WhirledTestServer.class);
        try {
            server.init(injector);
            server.run();
        } catch (Exception e) {
            log.warning("Unable to initialize server.", e);
        }
    }

    @Override // from CrowdServer
    public void init (Injector injector)
        throws Exception
    {
        super.init(injector);

        // we need to register with the shutdowner
        _shutmgr.registerShutdowner(this);

        // configure the client manager to use the appropriate client class
        _clmgr.setClientFactory(new ClientFactory() {
            public Class<? extends PresentsClient> getClientClass (AuthRequest areq) {
                return WhirledTestClient.class;
            }
            public Class<? extends ClientResolver> getClientResolverClass (Name username) {
                return WhirledTestClientResolver.class;
            }
        });

        // initialize our managers
        GameManager.setUserIdentifier(new GameManager.UserIdentifier() {
            public int getUserId (BodyObject bobj) {
                String username = bobj.username.toString();
                try {
                    return Integer.parseInt(username.substring(username.lastIndexOf("_")+1));
                } catch (Exception e) {
                    return 0;
                }
            }
        });
        _dictmgr.init("data/dictionary");

        // create and start up our HTTP server
        _httpServer = new WhirledHttpServer(getDocRoot());
        _httpServer.start();

        _policyServer = PolicyServer.init(47623, "localhost", getListenPorts(), 99999);

        // register ourselves as handling the test service
        _invmgr.registerDispatcher(new TestDispatcher(this), InvocationCodes.GLOBAL_GROUP);

        _bureauReg.init();
        _bureauReg.addClientFactory(_clmgr);
        _bureauReg.setCommandGenerator(BureauTypes.THANE, this);

        _clmgr.addClientObserver(new ClientManager.ClientObserver () {
            public void clientSessionDidEnd (PresentsClient client) {
                // shut down the server when the last non-buraeu disconnects
                if (_clmgr.getConnectionCount() == 0 || 
                    (_clmgr.getConnectionCount() == 1 && _hasBureau)) {
                    _shutmgr.shutdown();
                }
            }
            public void clientSessionDidStart (PresentsClient client) {
                // set the bureau flag if not a test client
                if (!(client instanceof WhirledTestClient)) {
                    _hasBureau = true;
                }
            }
            protected boolean _hasBureau;
        });

        // prepare the game and start the clients
        prepareGame();
    }

    // from interface ShutdownManager.Shutdowner
    public void shutdown ()
    {
        // shut down our http server
        try {
            _httpServer.stop();
        } catch (Exception e) {
            reportError("Failed to stop http server.", e);
        }

        _policyServer.unbindAll();
    }

    // from interface TestProvider
    public void clientReady (ClientObject caller)
    {
        // if this is a party game, send the player straight in, it's already running
        if (_gameMgr != null) {
            ParlorSender.gameIsReady(caller, _gameMgr.getPlaceObject().getOid());
            return;
        }

        // otherwise add them to the ready set and start the game when everyone is logged on
        _ready.add(((BodyObject)caller).username);
        Set<Name> ready = CollectionUtil.addAll(new HashSet<Name>(), _config.players);
        ready.retainAll(_ready);
        if (ready.size() == _config.players.length) {
            createGameManager(_config);
            _ready.clear();
        }
    }

    public String[] createCommand (
        String bureauId,
        String token)
    {
        ABCLibs abcLibs = new ABCLibs();
        List<String> args = Lists.newArrayList();
        args.add(System.getProperty("thane.path"));
        args.add("-Dinterp");
        args.addAll(abcLibs.getLibs("game-server-lib.", "game-server."));
        args.add("--");
        args.add(bureauId);
        args.add(token);
        args.add(String.valueOf(getListenPorts()[0]));
        log.info("Bureau arguments: " + StringUtil.toString(args));
        return args.toArray(new String[args.size()]);
    }

    protected void prepareGame ()
    {
        // parse the game configuration
        GameDefinition gamedef = null;
        try {
            gamedef = new TestGameParser().parseGame(getGameConfig());
        } catch (FileNotFoundException fnfe) {
            log.info("Unable to locate 'config.xml', no custom game config options will be set.");

        } catch (Exception e) {
            log.warning("Failed to parse 'config.xml' file. [error=" + e + "].");
        }
        if (gamedef == null) {
            gamedef = new TestGameDefinition();
            gamedef.params = new Parameter[0];
        }

        // add our standard test initializations
        gamedef.ident = "game";
        gamedef.controller = "com.whirled.game.client.TestGameController";
        gamedef.manager = "com.whirled.game.server.TestGameManager";

        if (hasServerSideCode()) {
            log.info("Server side code detected, setting game definition");
            ((TestGameDefinition)gamedef).hasServer = true;
        }

        // figure out how many players will be involved in the test game
        int pcount = getIntProperty("players", 1);
        int remoteCount = getIntProperty("remotePlayers", 0);
        int playerCount = pcount + remoteCount;
        TableMatchConfig match = new TableMatchConfig();
        match.minSeats = match.maxSeats = match.startSeats = pcount;
        match.isPartyGame = Boolean.getBoolean("party");
        gamedef.match = match;

        // set up our game configuration and start up the game clients
        _config = new WhirledGameConfig(-1, gamedef);
        _config.players = new Name[match.isPartyGame ? 0 : playerCount];
        for (int ii = 0; ii < playerCount; ii++) {
            Name name = new Name("tester_" + (ii+1));
            if (!match.isPartyGame) {
                _config.players[ii] = name;
            }

            // start up a Flash client for this player if it's not a remotePlayer
            if (ii < pcount) {
                String player = getFlashPlayerPath();
                String url = "http://localhost:8080/game-client.swf?username=" + name;
                try {
                    Process proc = Runtime.getRuntime().exec(new String[] { player, url });
                    new StreamEater(proc.getErrorStream());
                } catch (Exception e) {
                    reportError("Failed to start client [player=" + player +
                                ", url=" + url + "].", e);
                }
            }
        }

        // if this is a party game, start it up immediately
        if (match.isPartyGame) {
            _gameMgr = createGameManager(_config);
        }
    }

    protected boolean hasServerSideCode ()
    {
        File thanePath = new File(System.getProperty("thane.path"));
        File serverCodePath = new File(
            getDocRoot() + File.separator + "game.abc");
        return thanePath.length() != 0 && serverCodePath.exists() && 
            thanePath.exists();
    }

    protected WhirledGameManager createGameManager (WhirledGameConfig config)
    {
        try {
            return (WhirledGameManager)_plreg.createPlace(config);

        } catch (Exception e) {
            reportError("Failed to start game " + config + ".", e);
            return null;
        }
    }

    protected void reportError (String message, Exception e)
    {
        log.warning(message, e);
    }

    protected String getDocRoot ()
    {
        return System.getProperty("whirled.root") + File.separator + "dist";
    }

    protected Reader getGameConfig ()
        throws IOException
    {
        return new FileReader("config.xml");
    }

    protected int getIntProperty (String property, int defaultValue)
    {
        try {
            return Integer.getInteger(property, defaultValue);
        } catch (Exception e) {
            log.warning("Failed to parse '" + property + "' system property " +
                        "[value=" + System.getProperty(property) + ", error=" + e + "].");
            return defaultValue;
        }
    }

    protected String getFlashPlayerPath ()
    {
        return System.getProperty("flash.player");
    }

    /** Wee helper class to eat the streams of a launched process. */
    protected static class StreamEater extends Thread
    {
        public StreamEater (InputStream s)
        {
            super("Stream eater");
            setDaemon(true);
            _stream = s;

            try {
                setPriority(MIN_PRIORITY);
            } catch (Exception e) {
                // no matter...
            }
            start();
        }

        public void run ()
        {
            // discard everything
            try {
                while (_stream.read() != -1) {}
            } catch (IOException ioe) {
                // ignored
            }
        }

        protected InputStream _stream;
    } // END: static class StreamEater

    /** Local class to help us fish out abc files from our http root. */
    protected class ABCLibs
    {
        /** Creates a new instance. */
        public ABCLibs ()
        {
            // add libraries in "dist"
            addLibs(new File(getDocRoot(), ""));

            // add libraries in "dist/lib"
            addLibs(new File(getDocRoot(), "lib"));
        }

        /** Returns a list of strings consisting of the absolute paths of abc files that start 
         *  with each of the given prefixes, in order. */
        public List<String> getLibs (String ... prefixes)
        {
            List<String> libs = Lists.newArrayList();
            for (String prefix : prefixes) {
                String lib = getLib(prefix);
                if (lib != null) {
                    libs.add(lib);
                }
            }
            return libs;
        }

        /** Finds an abc file with the given prefix in our set of libs and return its 
         *  absolute path. */
        protected String getLib (String prefix)
        {
            for (File lib : _libs) {
                if (lib.getName().startsWith(prefix)) {
                    return lib.getAbsolutePath();
                }
            }
            log.warning("Could not find libary '" + prefix + "*.abc'");
            return null;
        }
        
        /* Scans the given directory for abc files and adds each one to our collection. */
        protected void addLibs (File dir)
        {
            File[] contents = dir.listFiles();
            if (contents == null) {
                log.warning("Could not open dist/lib directory in " + 
                    dir.getAbsolutePath());
                return;
            }
            
            for (File file : contents) {
                if (file.getName().endsWith(".abc")) {
                    _libs.add(file);
                }
            }
        }

        /** Our collection of abc files. */
        protected List<File> _libs = Lists.newArrayList();
    }

    /** The configuration for the game we'll start when everyone is ready. */
    protected WhirledGameConfig _config;

    /** Serves up SWF files to avoid annoying file-system-loaded SWF "seurity" problems. */
    protected WhirledHttpServer _httpServer;

    /** The manager for our test game. */
    protected WhirledGameManager _gameMgr;

    /** Contains a mapping of all clients that are ready to play. */
    protected Set<Name> _ready = Sets.newHashSet();

    /** A policy server. */
    protected IoAcceptor _policyServer;

    /** Handles parlor game services. */
    @Inject protected ParlorManager _parmgr;

    /** Handles bureau services. */
    @Inject protected BureauRegistry _bureauReg;

    /** Handles dictionary services. */
    @Inject protected DictionaryManager _dictmgr;
}
