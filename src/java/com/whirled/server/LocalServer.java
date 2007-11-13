//
// $Id$

package com.whirled.server;

import java.util.List;
import java.util.logging.Level;

import com.threerings.util.Name;

import com.threerings.presents.client.Client;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.net.BootstrapData;

import com.threerings.presents.server.ClientResolutionListener;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.LocalDObjectMgr;
import com.threerings.presents.server.PresentsDObjectMgr;

import com.threerings.crowd.server.CrowdServer;

import com.threerings.ezgame.server.EZGameManager;

import com.whirled.client.WhirledClient;

import static com.whirled.Log.log;

/**
 * Runs inside the standalone test client and handles the server side of things.
 */
public class LocalServer extends CrowdServer
{
    /** The parlor manager in operation on this server. */
    public static WhirledParlorManager parmgr = new WhirledParlorManager();

    /**
     * Initializes all of the server services and prepares for operation.
     */
    public void init ()
        throws Exception
    {
        // do the base server initialization
        super.init();

        // initialize our managers
        parmgr.init(invmgr, plreg);

        log.info("Local server initialized.");
    }

    /**
     * Called in standalone mode to cause the standalone client to "logon".
     */
    public void startStandaloneClient (final WhirledClient client, Name username)
    {
        // create our client object
        ClientResolutionListener clr = new ClientResolutionListener() {
            public void clientResolved (Name username, ClientObject clobj) {
                // flag the client as standalone
                Client pclient = client.getContext().getClient();
                String[] groups = pclient.prepareStandaloneLogon();

                // fake up a bootstrap; I need to expose the mechanisms in Presents that create it
                // in a network environment
                BootstrapData data = new BootstrapData();
                data.clientOid = clobj.getOid();
                data.services = invmgr.getBootstrapServices(groups);

                // and configure the client to use the server's distributed object manager
                pclient.standaloneLogon(
                    data, ((LocalDObjectMgr)omgr).getClientDObjectMgr(clobj.getOid()));
            }

            public void resolutionFailed (Name username, Exception cause) {
                log.log(Level.WARNING, "Failed to resolve client [who=" + username + "].", cause);
                // TODO: display this error
            }
        };
        clmgr.resolveClientObject(username, clr);
    }

    /**
     * Called in standalone mode to cause the standalone client to "logoff".
     */
    public void stopStandaloneClient (WhirledClient client)
    {
        client.getContext().getClient().standaloneLogoff();
    }

    @Override // documentation inherited
    protected PresentsDObjectMgr createDObjectManager ()
    {
        return new LocalDObjectMgr();
    }
}
