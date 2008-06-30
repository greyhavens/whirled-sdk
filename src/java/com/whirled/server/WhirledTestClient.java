//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.server;

import com.google.inject.Inject;

import com.threerings.presents.server.ShutdownManager;
import com.threerings.crowd.server.CrowdClient;

/**
 * Handles shutting down the test server when all users have logged off or disconnected.
 */
public class WhirledTestClient extends CrowdClient
{
    @Override // from CrowdClient
    protected void sessionConnectionClosed ()
    {
        super.sessionConnectionClosed();

        // end our session on disconnect, it's easy enough to get back to where you were with a
        // browser reload
        if (_clobj != null) {
            safeEndSession();
        }

        // shut down the server when the last person disconnects
        if (_clmgr.getConnectionCount() == 0) {
            _shutmgr.shutdown();
        }
    }

    @Inject protected ShutdownManager _shutmgr;
}
