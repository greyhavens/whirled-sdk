//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.data {

import com.threerings.io.TypedArray;
import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService_InvocationListener;
import com.threerings.presents.data.InvocationMarshaller;
import com.threerings.presents.data.InvocationMarshaller_ListenerMarshaller;
import com.whirled.game.client.WhirledGameMessageService;

/**
 * Provides the implementation of the <code>WhirledGameMessageService</code> interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
public class WhirledGameMessageMarshaller extends InvocationMarshaller
    implements WhirledGameMessageService
{
    /** The method id used to dispatch <code>sendMessage</code> requests. */
    public static const SEND_MESSAGE :int = 1;

    // from interface WhirledGameMessageService
    public function sendMessage (arg1 :Client, arg2 :String, arg3 :Object, arg4 :InvocationService_InvocationListener) :void
    {
        var listener4 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener4.listener = arg4;
        sendRequest(arg1, SEND_MESSAGE, [
            arg2, arg3, listener4
        ]);
    }

    /** The method id used to dispatch <code>sendPrivateMessage</code> requests. */
    public static const SEND_PRIVATE_MESSAGE :int = 2;

    // from interface WhirledGameMessageService
    public function sendPrivateMessage (arg1 :Client, arg2 :String, arg3 :Object, arg4 :TypedArray /* of int */, arg5 :InvocationService_InvocationListener) :void
    {
        var listener5 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener5.listener = arg5;
        sendRequest(arg1, SEND_PRIVATE_MESSAGE, [
            arg2, arg3, arg4, listener5
        ]);
    }
}
}
