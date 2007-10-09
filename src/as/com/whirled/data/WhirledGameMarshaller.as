//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.data {

import flash.utils.ByteArray;
import com.threerings.util.*; // for Float, Integer, etc.
import com.threerings.io.TypedArray;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService_InvocationListener;
import com.threerings.presents.data.InvocationMarshaller;
import com.threerings.presents.data.InvocationMarshaller_ListenerMarshaller;
import com.whirled.client.WhirledGameService;

/**
 * Provides the implementation of the {@link WhirledGameService} interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
public class WhirledGameMarshaller extends InvocationMarshaller
    implements WhirledGameService
{
    /** The method id used to dispatch {@link #awardTrophy} requests. */
    public static const AWARD_TROPHY :int = 1;

    // from interface WhirledGameService
    public function awardTrophy (arg1 :Client, arg2 :String, arg3 :InvocationService_InvocationListener) :void
    {
        var listener3 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener3.listener = arg3;
        sendRequest(arg1, AWARD_TROPHY, [
            arg2, listener3
        ]);
    }

    /** The method id used to dispatch {@link #endGameWithScores} requests. */
    public static const END_GAME_WITH_SCORES :int = 2;

    // from interface WhirledGameService
    public function endGameWithScores (arg1 :Client, arg2 :TypedArray /* of int */, arg3 :TypedArray /* of int */, arg4 :int, arg5 :InvocationService_InvocationListener) :void
    {
        var listener5 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener5.listener = arg5;
        sendRequest(arg1, END_GAME_WITH_SCORES, [
            arg2, arg3, Integer.valueOf(arg4), listener5
        ]);
    }

    /** The method id used to dispatch {@link #endGameWithWinners} requests. */
    public static const END_GAME_WITH_WINNERS :int = 3;

    // from interface WhirledGameService
    public function endGameWithWinners (arg1 :Client, arg2 :TypedArray /* of int */, arg3 :TypedArray /* of int */, arg4 :int, arg5 :InvocationService_InvocationListener) :void
    {
        var listener5 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener5.listener = arg5;
        sendRequest(arg1, END_GAME_WITH_WINNERS, [
            arg2, arg3, Integer.valueOf(arg4), listener5
        ]);
    }
}
}
