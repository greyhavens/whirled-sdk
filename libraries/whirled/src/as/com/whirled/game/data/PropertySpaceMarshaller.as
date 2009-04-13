//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.data {

import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService_InvocationListener;
import com.threerings.presents.data.InvocationMarshaller;
import com.threerings.presents.data.InvocationMarshaller_ListenerMarshaller;
import com.threerings.util.Integer;
import com.threerings.util.langBoolean;
import com.whirled.game.client.PropertySpaceService;

/**
 * Provides the implementation of the <code>PropertySpaceService</code> interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
public class PropertySpaceMarshaller extends InvocationMarshaller
    implements PropertySpaceService
{
    /** The method id used to dispatch <code>setProperty</code> requests. */
    public static const SET_PROPERTY :int = 1;

    // from interface PropertySpaceService
    public function setProperty (arg1 :Client, arg2 :String, arg3 :Object, arg4 :Integer, arg5 :Boolean, arg6 :Boolean, arg7 :Object, arg8 :InvocationService_InvocationListener) :void
    {
        var listener8 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener8.listener = arg8;
        sendRequest(arg1, SET_PROPERTY, [
            arg2, arg3, arg4, langBoolean.valueOf(arg5), langBoolean.valueOf(arg6), arg7, listener8
        ]);
    }
}
}
