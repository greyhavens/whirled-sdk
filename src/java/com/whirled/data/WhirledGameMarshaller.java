//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.data;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.InvocationMarshaller;
import com.threerings.presents.dobj.InvocationResponseEvent;
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
    public static final int AWARD_TROPHY = 1;

    // from interface WhirledGameService
    public void awardTrophy (Client arg1, String arg2, InvocationService.InvocationListener arg3)
    {
        ListenerMarshaller listener3 = new ListenerMarshaller();
        listener3.listener = arg3;
        sendRequest(arg1, AWARD_TROPHY, new Object[] {
            arg2, listener3
        });
    }

    /** The method id used to dispatch {@link #endGameWithScores} requests. */
    public static final int END_GAME_WITH_SCORES = 2;

    // from interface WhirledGameService
    public void endGameWithScores (Client arg1, int[] arg2, int[] arg3, int arg4, InvocationService.InvocationListener arg5)
    {
        ListenerMarshaller listener5 = new ListenerMarshaller();
        listener5.listener = arg5;
        sendRequest(arg1, END_GAME_WITH_SCORES, new Object[] {
            arg2, arg3, Integer.valueOf(arg4), listener5
        });
    }

    /** The method id used to dispatch {@link #endGameWithWinners} requests. */
    public static final int END_GAME_WITH_WINNERS = 3;

    // from interface WhirledGameService
    public void endGameWithWinners (Client arg1, int[] arg2, int[] arg3, int arg4, InvocationService.InvocationListener arg5)
    {
        ListenerMarshaller listener5 = new ListenerMarshaller();
        listener5.listener = arg5;
        sendRequest(arg1, END_GAME_WITH_WINNERS, new Object[] {
            arg2, arg3, Integer.valueOf(arg4), listener5
        });
    }
}
