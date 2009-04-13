//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.client {

import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.client.InvocationService_InvocationListener;
import com.threerings.util.Integer;

/**
 * An ActionScript version of the Java PropertySpaceService interface.
 */
public interface PropertySpaceService extends InvocationService
{
    // from Java interface PropertySpaceService
    function setProperty (arg1 :Client, arg2 :String, arg3 :Object, arg4 :Integer, arg5 :Boolean, arg6 :Boolean, arg7 :Object, arg8 :InvocationService_InvocationListener) :void;
}
}
