//
// $Id$

package com.whirled.server;

import java.util.List;
import java.util.logging.Level;

import com.google.common.collect.Lists;
import com.google.inject.Injector;

import com.threerings.util.Name;

import com.threerings.presents.client.Client;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.net.BootstrapData;

import com.threerings.presents.server.ClientResolutionListener;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.LocalDObjectMgr;
import com.threerings.presents.server.PresentsDObjectMgr;

import com.threerings.crowd.server.CrowdServer;
import com.threerings.crowd.server.PlaceManager;
import com.threerings.crowd.server.PlaceManagerDelegate;

import com.threerings.parlor.game.data.GameConfig;
import com.threerings.parlor.server.ParlorManager;

import com.whirled.client.WhirledTestClient;

import static com.whirled.Log.log;

/**
 * Runs inside the standalone test client and handles the server side of things.
 */
public class LocalServer extends CrowdServer
{
    /** Configures dependencies needed by the local Whirled server. */
    public static class Module extends CrowdServer.Module
    {
        @Override protected void configure () {
            super.configure();
            bind(PresentsDObjectMgr.class).to(LocalDObjectMgr.class);
        }
    }

    /** The parlor manager in operation on this server. */
    public static ParlorManager parmgr = new ParlorManager() {
        @Override protected void createGameManager (GameConfig config)
            throws InstantiationException, InvocationException
        {
            _plreg.createPlace(config);
        }
    };

    @Override // from CrowdServer
    public void init (Injector injector)
        throws Exception
    {
        super.init(injector);

        // initialize our managers
        parmgr.init(invmgr, plreg);

        log.info("Local server initialized.");
    }

    /**
     * Called in standalone mode to cause the standalone client to "logon".
     */
    public void startStandaloneClient (final WhirledTestClient client, Name username)
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
                log.warning("Failed to resolve client [who=" + username + "].", cause);
                // TODO: display this error
            }
        };
        clmgr.resolveClientObject(username, clr);
    }

    /**
     * Called in standalone mode to cause the standalone client to "logoff".
     */
    public void stopStandaloneClient (WhirledTestClient client)
    {
        client.getContext().getClient().standaloneLogoff();
    }
}
