//
// $Id$

package com.whirled.data {

import flash.utils.ByteArray;
import com.threerings.util.*; // for Float, Integer, etc.

import com.threerings.presents.client.Client;
import com.threerings.presents.data.InvocationMarshaller;
import com.threerings.presents.data.InvocationMarshaller_ListenerMarshaller;
import com.whirled.client.TestService;

/**
 * Provides the implementation of the {@link TestService} interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
public class TestMarshaller extends InvocationMarshaller
    implements TestService
{
    /** The method id used to dispatch {@link #clientReady} requests. */
    public static const CLIENT_READY :int = 1;

    // from interface TestService
    public function clientReady (arg1 :Client) :void
    {
        sendRequest(arg1, CLIENT_READY, [
            
        ]);
    }
}
}
