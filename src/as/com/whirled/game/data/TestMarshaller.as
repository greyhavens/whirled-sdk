//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.data {

import com.threerings.presents.data.InvocationMarshaller;
import com.whirled.game.client.TestService;

/**
 * Provides the implementation of the <code>TestService</code> interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
public class TestMarshaller extends InvocationMarshaller
    implements TestService
{
    /** The method id used to dispatch <code>clientReady</code> requests. */
    public static const CLIENT_READY :int = 1;

    // from interface TestService
    public function clientReady () :void
    {
        sendRequest(CLIENT_READY, [
            
        ]);
    }
}
}
