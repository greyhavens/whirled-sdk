//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.server;

import com.threerings.presents.dobj.AccessController;
import com.threerings.presents.dobj.DEvent;
import com.threerings.presents.dobj.DObject;
import com.threerings.presents.dobj.Subscriber;

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

    @Override // from PresentsSession
    protected void sessionWillStart ()
    {
        super.sessionWillStart();

        // Let everyone have full access to our test client object
        _clobj.setAccessController(new AccessController () {
            public boolean allowSubscribe (DObject object, Subscriber<?> subscriber) {
                return true;
            }

            public boolean allowDispatch (DObject object, DEvent event) {
                return true;
            }
        });

    }
}
