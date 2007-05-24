//
// $Id$

package com.whirled.server;

import java.util.logging.Level;

import com.samskivert.util.LoggingLogProvider;
import com.samskivert.util.OneLineLogFormatter;

import com.threerings.presents.dobj.RootDObjectManager;
import com.threerings.presents.server.InvocationManager;

import com.threerings.crowd.data.PlaceConfig;
import com.threerings.crowd.server.CrowdServer;
import com.threerings.crowd.server.PlaceRegistry;

import com.threerings.parlor.server.ParlorManager;
import com.threerings.ezgame.server.DictionaryManager;

import static com.whirled.Log.log;

/**
 * Handles setting up the Whirled standalone test server.
 */
public class WhirledServer extends CrowdServer
{
    /** Handles creating and cleaning up after games. */
    public static ParlorManager parMan = new ParlorManager();

    /** Serves up SWF files to avoid annoying file-system-loaded SWF "seurity" problems. */
    public static WhirledHttpServer httpServer;

    public static void main (String[] args)
    {
        // set up the proper logging services
        com.samskivert.util.Log.setLogProvider(new LoggingLogProvider());
        OneLineLogFormatter.configureDefaultHandler();

        WhirledServer server = new WhirledServer();
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

        // initialize our managers
        parMan.init(invmgr, plreg);
        DictionaryManager.init("data/dictionary");

        // create and start up our HTTP server
        httpServer = new WhirledHttpServer();
        httpServer.init();
    }

    @Override // from PresentsServer
    public void shutdown ()
    {
        super.shutdown();

        // shut down our http server
        try {
            httpServer.stop(true);
        } catch (InterruptedException ie) {
            log.log(Level.WARNING, "Failed to stop http server.", ie);
        }
    }
}
