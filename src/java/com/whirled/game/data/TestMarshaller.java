//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.data;

import com.threerings.presents.client.Client;
import com.threerings.presents.data.InvocationMarshaller;
import com.whirled.game.client.TestService;

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
    public static final int CLIENT_READY = 1;

    // from interface TestService
    public void clientReady (Client arg1)
    {
        sendRequest(arg1, CLIENT_READY, new Object[] {

        });
    }
}
