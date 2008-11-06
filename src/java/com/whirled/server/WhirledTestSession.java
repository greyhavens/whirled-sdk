//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.server;

import com.google.inject.Inject;

import com.threerings.presents.server.ShutdownManager;
import com.threerings.crowd.server.CrowdSession;

/**
 * Handles shutting down the test server when all users have logged off or disconnected.
 */
public class WhirledTestSession extends CrowdSession
{
    @Override // from CrowdSession
    protected void sessionConnectionClosed ()
    {
        super.sessionConnectionClosed();

        // end our session on disconnect, it's easy enough to get back to where you were with a
        // browser reload
        if (_clobj != null) {
            safeEndSession();
        }
    }
}
