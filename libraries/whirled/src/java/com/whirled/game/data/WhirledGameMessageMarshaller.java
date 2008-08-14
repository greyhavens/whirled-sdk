//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.data;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.InvocationMarshaller;
import com.whirled.game.client.WhirledGameMessageService;

/**
 * Provides the implementation of the {@link WhirledGameMessageService} interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
public class WhirledGameMessageMarshaller extends InvocationMarshaller
    implements WhirledGameMessageService
{
    /** The method id used to dispatch {@link #sendMessage} requests. */
    public static final int SEND_MESSAGE = 1;

    // from interface WhirledGameMessageService
    public void sendMessage (Client arg1, String arg2, Object arg3, int arg4, int arg5, InvocationService.InvocationListener arg6)
    {
        ListenerMarshaller listener6 = new ListenerMarshaller();
        listener6.listener = arg6;
        sendRequest(arg1, SEND_MESSAGE, new Object[] {
            arg2, arg3, Integer.valueOf(arg4), Integer.valueOf(arg5), listener6
        });
    }
}
