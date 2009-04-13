//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.client {

import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.client.InvocationService_InvocationListener;

/**
 * An ActionScript version of the Java PrizeService interface.
 */
public interface PrizeService extends InvocationService
{
    // from Java interface PrizeService
    function awardPrize (arg1 :Client, arg2 :String, arg3 :int, arg4 :InvocationService_InvocationListener) :void;

    // from Java interface PrizeService
    function awardTrophy (arg1 :Client, arg2 :String, arg3 :int, arg4 :InvocationService_InvocationListener) :void;
}
}
