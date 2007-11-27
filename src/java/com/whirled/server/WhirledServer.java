//
// $Id$

package com.whirled.server;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.Reader;

import java.util.HashSet;
import java.util.List;
import java.util.logging.Level;

import com.google.common.collect.Lists;

import com.samskivert.util.CollectionUtil;
import com.samskivert.util.LoggingLogProvider;
import com.samskivert.util.OneLineLogFormatter;
import com.threerings.util.Name;

import com.threerings.presents.data.ClientObject;
import com.threerings.presents.data.InvocationCodes;
import com.threerings.presents.dobj.RootDObjectManager;
import com.threerings.presents.net.AuthRequest;
import com.threerings.presents.server.ClientFactory;
import com.threerings.presents.server.ClientResolver;
import com.threerings.presents.server.InvocationManager;
import com.threerings.presents.server.PresentsClient;

import com.threerings.crowd.data.BodyObject;
import com.threerings.crowd.data.PlaceConfig;
import com.threerings.crowd.server.CrowdClientResolver;
import com.threerings.crowd.server.CrowdServer;
import com.threerings.crowd.server.PlaceManagerDelegate;

import com.threerings.parlor.game.server.GameManager;
import com.threerings.parlor.server.ParlorManager;
import com.threerings.parlor.server.ParlorSender;

import com.threerings.ezgame.data.EZGameConfig;
import com.threerings.ezgame.data.GameDefinition;
import com.threerings.ezgame.data.Parameter;
import com.threerings.ezgame.data.TableMatchConfig;
import com.threerings.ezgame.server.DictionaryManager;
import com.threerings.ezgame.server.EZGameManager;

import com.whirled.data.WhirledGameDefinition;
import com.whirled.xml.WhirledGameParser;

import static com.whirled.Log.log;

/**
 * Handles setting up the Whirled standalone test server.
 */
public class WhirledServer extends CrowdServer
    implements TestProvider
{
    /** The singleton server instance. */
    public static WhirledServer server;

    /** Handles creating and cleaning up after games. */
    public static ParlorManager parMan = new ParlorManager();

    /** Serves up SWF files to avoid annoying file-system-loaded SWF "seurity" problems. */
    public static WhirledHttpServer httpServer;

    public static void main (String[] args)
    {
        // set up the proper logging services
        com.samskivert.util.Log.setLogProvider(new LoggingLogProvider());
        OneLineLogFormatter.configureDefaultHandler();

        server = new WhirledServer();
        try {
            server.init();
            server.run();
        } catch (Exception e) {
            log.log(Level.WARNING, "Unable to initialize server.", e);
        }
    }

    @Override // from PresentsServer
    public void init ()
        throws Exception
    {
        // do the base server initialization
        super.init();

        // configure the client manager to use the appropriate client class
        clmgr.setClientFactory(new ClientFactory() {
            public PresentsClient createClient (AuthRequest areq) {
                return new WhirledClient();
            }
            public ClientResolver createClientResolver (Name username) {
                return new CrowdClientResolver();
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

        // register ourselves as handling the test service
        invmgr.registerDispatcher(new TestDispatcher(this), InvocationCodes.GLOBAL_GROUP);

        // prepare the game and start the clients
        prepareGame();
    }

    @Override // from PresentsServer
    public void shutdown ()
    {
        super.shutdown();

        // shut down our http server
        try {
            httpServer.stop();
        } catch (Exception e) {
            reportError("Failed to stop http server.", e);
        }
    }

    // from interface TestProvider
    public void clientReady (ClientObject caller)
    {
        // if this is a party game, send the player straight in, it's already running
        if (_ezmgr != null) {
            ParlorSender.gameIsReady(caller, _ezmgr.getPlaceObject().getOid());
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

    protected void prepareGame ()
    {
        // parse the game configuration
        GameDefinition gamedef;
        try {
            gamedef = new WhirledGameParser().parseGame(getGameConfig());
        } catch (Exception e) {
            log.warning("Failed to locate 'config.xml' file. [error=" + e + "].");
            gamedef = new WhirledGameDefinition();
            gamedef.params = new Parameter[0];
        }

        // add our standard test initializations
        gamedef.ident = "game";
        gamedef.controller = "com.whirled.client.TestGameController";
        gamedef.manager = "com.whirled.server.TestGameManager";

        // figure out how many players will be involved in the test game
        int pcount = getIntProperty("players", 1);
        int remoteCount = getIntProperty("remotePlayers", 0);
        int playerCount = pcount + remoteCount;
        TableMatchConfig match = new TableMatchConfig();
        match.minSeats = match.maxSeats = match.startSeats = pcount;
        match.isPartyGame = Boolean.getBoolean("party");
        gamedef.match = match;

        // set up our game configuration and start up the game clients
        _config = new EZGameConfig(-1, gamedef);
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
            _ezmgr = createGameManager(_config);
        }
    }

    protected EZGameManager createGameManager (EZGameConfig config)
    {
        try {
            List<PlaceManagerDelegate> delegates = Lists.newArrayList();
            delegates.add(new WhirledGameManagerDelegate());
            return (EZGameManager)plreg.createPlace(config, delegates);

        } catch (Exception e) {
            reportError("Failed to start game " + config + ".", e);
            return null;
        }
    }

    protected void reportError (String message, Exception e)
    {
        log.log(Level.WARNING, message, e);
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

    /** The configuration for the game we'll start when everyone is ready. */
    protected EZGameConfig _config;

    /** The manager for our test game. */
    protected EZGameManager _ezmgr;

    /** Contains a mapping of all clients that are ready to play. */
    protected HashSet<Name> _ready = new HashSet<Name>();
}
