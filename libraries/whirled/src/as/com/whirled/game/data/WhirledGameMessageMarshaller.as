//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.data {

import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService_InvocationListener;
import com.threerings.presents.data.InvocationMarshaller;
import com.threerings.presents.data.InvocationMarshaller_ListenerMarshaller;
import com.threerings.util.Integer;
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
    public function sendMessage (arg1 :Client, arg2 :String, arg3 :Object, arg4 :int, arg5 :int, arg6 :InvocationService_InvocationListener) :void
    {
        var listener6 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener6.listener = arg6;
        sendRequest(arg1, SEND_MESSAGE, [
            arg2, arg3, Integer.valueOf(arg4), Integer.valueOf(arg5), listener6
        ]);
    }
}
}
