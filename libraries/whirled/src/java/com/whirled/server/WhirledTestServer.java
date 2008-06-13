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
import java.util.logging.Level;

import org.apache.mina.common.IoAcceptor;

import com.google.common.collect.Lists;
import com.google.inject.Guice;
import com.google.inject.Injector;

import com.samskivert.util.CollectionUtil;
import com.threerings.util.Name;
import com.samskivert.util.StringUtil;

import com.threerings.presents.data.ClientObject;
import com.threerings.presents.data.InvocationCodes;
import com.threerings.presents.dobj.RootDObjectManager;
import com.threerings.presents.net.AuthRequest;
import com.threerings.presents.server.ClientFactory;
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

import com.whirled.game.data.WhirledGameConfig;
import com.whirled.game.data.GameDefinition;
import com.whirled.game.data.TableMatchConfig;
import com.whirled.game.data.TestGameDefinition;
import com.whirled.game.server.DictionaryManager;
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
    /** The singleton server instance. */
    public static WhirledTestServer server;

    /** Handles creating and cleaning up after games. */
    public static ParlorManager parMan = new ParlorManager();

    /** Serves up SWF files to avoid annoying file-system-loaded SWF "seurity" problems. */
    public static WhirledHttpServer httpServer;

    /** Keeps track of bureaus launched by this server. It is up to subclasses to register the 
     *  desired bureau types. Otherwise none will be launched. */
    public static BureauRegistry bureauReg;

    /**
     * The main entry point for the test server.
     */
    public static void main (String[] args)
    {
        Injector injector = Guice.createInjector(new Module());
        server = injector.getInstance(WhirledTestServer.class);
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
        clmgr.setClientFactory(new ClientFactory() {
            public Class<? extends PresentsClient> getClientClass (AuthRequest areq) {
                if (areq.getCredentials() instanceof BureauCredentials) {
                    return PresentsClient.class;
                }
                return WhirledTestServerMonitor.class;
            }
            public Class<? extends ClientResolver> getClientResolverClass (Name username) {
                if (BureauCredentials.isBureau(username)) {
                    return ClientResolver.class;
                }
                return WhirledTestClientResolver.class;
            }
        });

        // initialize our managers
        parMan.init(invmgr, plreg);
        DictionaryManager.init("data/dictionary");
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

        // create and start up our HTTP server
        httpServer = new WhirledHttpServer(getDocRoot());
        httpServer.start();

        _policyServer = PolicyServer.init(47623, "localhost", getListenPorts(), 99999);

        // register ourselves as handling the test service
        invmgr.registerDispatcher(new TestDispatcher(this), InvocationCodes.GLOBAL_GROUP);

        // TODO: should the bureau have multiple ports?
        bureauReg = new BureauRegistry(
            "localhost:" + getListenPorts()[0], invmgr, omgr, invoker);

        bureauReg.setCommandGenerator(WhirledGameManager.THANE_BUREAU, this);

        // prepare the game and start the clients
        prepareGame();
    }

    // from interface ShutdownManager.Shutdowner
    public void shutdown ()
    {
        // shut down our http server
        try {
            httpServer.stop();
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
        HashSet<Name> ready = CollectionUtil.addAll(new HashSet<Name>(), _config.players);
        ready.retainAll(_ready);
        if (ready.size() == _config.players.length) {
            createGameManager(_config);
            _ready.clear();
        }
    }

    public String[] createCommand (
        String serverNameAndPort,
        String bureauId,
        String token)
    {
        String localhostPrefix = "localhost:";
        if (!serverNameAndPort.startsWith(localhostPrefix)) {
            log.warning("Cannot connect to " + 
                serverNameAndPort);
        }

        ABCLibs abcLibs = new ABCLibs();
        List<String> args = Lists.newArrayList();
        args.add(System.getProperty("thane.path"));
        args.addAll(abcLibs.getLibs(
            "game-server"));
        args.add("--");
        args.add(bureauId);
        args.add(token);
        args.add(serverNameAndPort.substring(localhostPrefix.length()));
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
        // !TODO: support some bureau action, create an agent and give it a ThaneGameConfig
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
                    reportError("Failed to start client [player=" + player + ", url=" + url + "].", e);
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
            return (WhirledGameManager)plreg.createPlace(config);

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

    /** The manager for our test game. */
    protected WhirledGameManager _gameMgr;

    /** Contains a mapping of all clients that are ready to play. */
    protected HashSet<Name> _ready = new HashSet<Name>();

    /** A policy server. */
    protected IoAcceptor _policyServer;
}
