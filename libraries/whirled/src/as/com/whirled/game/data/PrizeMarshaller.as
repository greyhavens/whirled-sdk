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
import com.whirled.game.client.PrizeService;

/**
 * Provides the implementation of the <code>PrizeService</code> interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
public class PrizeMarshaller extends InvocationMarshaller
    implements PrizeService
{
    /** The method id used to dispatch <code>awardPrize</code> requests. */
    public static const AWARD_PRIZE :int = 1;

    // from interface PrizeService
    public function awardPrize (arg1 :Client, arg2 :String, arg3 :int, arg4 :InvocationService_InvocationListener) :void
    {
        var listener4 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener4.listener = arg4;
        sendRequest(arg1, AWARD_PRIZE, [
            arg2, Integer.valueOf(arg3), listener4
        ]);
    }

    /** The method id used to dispatch <code>awardTrophy</code> requests. */
    public static const AWARD_TROPHY :int = 2;

    // from interface PrizeService
    public function awardTrophy (arg1 :Client, arg2 :String, arg3 :int, arg4 :InvocationService_InvocationListener) :void
    {
        var listener4 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener4.listener = arg4;
        sendRequest(arg1, AWARD_TROPHY, [
            arg2, Integer.valueOf(arg3), listener4
        ]);
    }
}
}
