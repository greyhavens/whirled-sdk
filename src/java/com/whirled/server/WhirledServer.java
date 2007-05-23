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

import static com.whirled.Log.log;

/**
 * Handles setting up the Whirled standalone test server.
 */
public class WhirledServer extends CrowdServer
{
    /** Handles creating and cleaning up after games. */
    public static ParlorManager parmgr = new ParlorManager();

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

//         // configure the client manager to use the appropriate client class
//         clmgr.setClientFactory(new ClientFactory() {
//             public PresentsClient createClient (AuthRequest areq) {
//                 return new WhirledClient();
//             }
//             public ClientResolver createClientResolver (Name username) {
//                 return new WhirledClientResolver();
//             }
//         });

        // initialize our managers
        parmgr.init(invmgr, plreg);

        log.info("Whirled test server initialized.");
    }

    @Override // from PresentsServer
    public void shutdown ()
    {
        super.shutdown();
        log.info("Whirled server shutting down.");
    }
}
