//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.server;

import com.threerings.crowd.server.CrowdClient;

/**
 * Handles shutting down the test server when all users have logged off or disconnected.
 */
public class WhirledClient extends CrowdClient
{
    // documentation inherited
    protected void sessionConnectionClosed ()
    {
        super.sessionConnectionClosed();

        if (_cmgr.getConnectionCount() == 0) {
            WhirledServer.server.shutdown();
        }
    }
}
