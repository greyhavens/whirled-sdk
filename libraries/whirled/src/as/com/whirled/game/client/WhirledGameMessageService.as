//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.client {

import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.client.InvocationService_InvocationListener;

/**
 * An ActionScript version of the Java WhirledGameMessageService interface.
 */
public interface WhirledGameMessageService extends InvocationService
{
    // from Java interface WhirledGameMessageService
    function sendMessage (arg1 :Client, arg2 :String, arg3 :Object, arg4 :int, arg5 :int, arg6 :InvocationService_InvocationListener) :void;
}
}
