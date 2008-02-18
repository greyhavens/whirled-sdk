//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.data;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.InvocationMarshaller;
import com.threerings.presents.dobj.InvocationResponseEvent;
import com.whirled.game.client.WhirledGameService;

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
    /** The method id used to dispatch {@link #addToCollection} requests. */
    public static final int ADD_TO_COLLECTION = 1;

    // from interface WhirledGameService
    public void addToCollection (Client arg1, String arg2, byte[][] arg3, boolean arg4, InvocationService.InvocationListener arg5)
    {
        ListenerMarshaller listener5 = new ListenerMarshaller();
        listener5.listener = arg5;
        sendRequest(arg1, ADD_TO_COLLECTION, new Object[] {
            arg2, arg3, Boolean.valueOf(arg4), listener5
        });
    }

    /** The method id used to dispatch {@link #awardPrize} requests. */
    public static final int AWARD_PRIZE = 2;

    // from interface WhirledGameService
    public void awardPrize (Client arg1, String arg2, InvocationService.InvocationListener arg3)
    {
        ListenerMarshaller listener3 = new ListenerMarshaller();
        listener3.listener = arg3;
        sendRequest(arg1, AWARD_PRIZE, new Object[] {
            arg2, listener3
        });
    }

    /** The method id used to dispatch {@link #awardTrophy} requests. */
    public static final int AWARD_TROPHY = 3;

    // from interface WhirledGameService
    public void awardTrophy (Client arg1, String arg2, InvocationService.InvocationListener arg3)
    {
        ListenerMarshaller listener3 = new ListenerMarshaller();
        listener3.listener = arg3;
        sendRequest(arg1, AWARD_TROPHY, new Object[] {
            arg2, listener3
        });
    }

    /** The method id used to dispatch {@link #checkDictionaryWord} requests. */
    public static final int CHECK_DICTIONARY_WORD = 4;

    // from interface WhirledGameService
    public void checkDictionaryWord (Client arg1, String arg2, String arg3, String arg4, InvocationService.ResultListener arg5)
    {
        InvocationMarshaller.ResultMarshaller listener5 = new InvocationMarshaller.ResultMarshaller();
        listener5.listener = arg5;
        sendRequest(arg1, CHECK_DICTIONARY_WORD, new Object[] {
            arg2, arg3, arg4, listener5
        });
    }

    /** The method id used to dispatch {@link #endGame} requests. */
    public static final int END_GAME = 5;

    // from interface WhirledGameService
    public void endGame (Client arg1, int[] arg2, InvocationService.InvocationListener arg3)
    {
        ListenerMarshaller listener3 = new ListenerMarshaller();
        listener3.listener = arg3;
        sendRequest(arg1, END_GAME, new Object[] {
            arg2, listener3
        });
    }

    /** The method id used to dispatch {@link #endGameWithScores} requests. */
    public static final int END_GAME_WITH_SCORES = 6;

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
    public static final int END_GAME_WITH_WINNERS = 7;

    // from interface WhirledGameService
    public void endGameWithWinners (Client arg1, int[] arg2, int[] arg3, int arg4, InvocationService.InvocationListener arg5)
    {
        ListenerMarshaller listener5 = new ListenerMarshaller();
        listener5.listener = arg5;
        sendRequest(arg1, END_GAME_WITH_WINNERS, new Object[] {
            arg2, arg3, Integer.valueOf(arg4), listener5
        });
    }

    /** The method id used to dispatch {@link #endRound} requests. */
    public static final int END_ROUND = 8;

    // from interface WhirledGameService
    public void endRound (Client arg1, int arg2, InvocationService.InvocationListener arg3)
    {
        ListenerMarshaller listener3 = new ListenerMarshaller();
        listener3.listener = arg3;
        sendRequest(arg1, END_ROUND, new Object[] {
            Integer.valueOf(arg2), listener3
        });
    }

    /** The method id used to dispatch {@link #endTurn} requests. */
    public static final int END_TURN = 9;

    // from interface WhirledGameService
    public void endTurn (Client arg1, int arg2, InvocationService.InvocationListener arg3)
    {
        ListenerMarshaller listener3 = new ListenerMarshaller();
        listener3.listener = arg3;
        sendRequest(arg1, END_TURN, new Object[] {
            Integer.valueOf(arg2), listener3
        });
    }

    /** The method id used to dispatch {@link #getCookie} requests. */
    public static final int GET_COOKIE = 10;

    // from interface WhirledGameService
    public void getCookie (Client arg1, int arg2, InvocationService.InvocationListener arg3)
    {
        ListenerMarshaller listener3 = new ListenerMarshaller();
        listener3.listener = arg3;
        sendRequest(arg1, GET_COOKIE, new Object[] {
            Integer.valueOf(arg2), listener3
        });
    }

    /** The method id used to dispatch {@link #getDictionaryLetterSet} requests. */
    public static final int GET_DICTIONARY_LETTER_SET = 11;

    // from interface WhirledGameService
    public void getDictionaryLetterSet (Client arg1, String arg2, String arg3, int arg4, InvocationService.ResultListener arg5)
    {
        InvocationMarshaller.ResultMarshaller listener5 = new InvocationMarshaller.ResultMarshaller();
        listener5.listener = arg5;
        sendRequest(arg1, GET_DICTIONARY_LETTER_SET, new Object[] {
            arg2, arg3, Integer.valueOf(arg4), listener5
        });
    }

    /** The method id used to dispatch {@link #getFromCollection} requests. */
    public static final int GET_FROM_COLLECTION = 12;

    // from interface WhirledGameService
    public void getFromCollection (Client arg1, String arg2, boolean arg3, int arg4, String arg5, int arg6, InvocationService.ConfirmListener arg7)
    {
        InvocationMarshaller.ConfirmMarshaller listener7 = new InvocationMarshaller.ConfirmMarshaller();
        listener7.listener = arg7;
        sendRequest(arg1, GET_FROM_COLLECTION, new Object[] {
            arg2, Boolean.valueOf(arg3), Integer.valueOf(arg4), arg5, Integer.valueOf(arg6), listener7
        });
    }

    /** The method id used to dispatch {@link #mergeCollection} requests. */
    public static final int MERGE_COLLECTION = 13;

    // from interface WhirledGameService
    public void mergeCollection (Client arg1, String arg2, String arg3, InvocationService.InvocationListener arg4)
    {
        ListenerMarshaller listener4 = new ListenerMarshaller();
        listener4.listener = arg4;
        sendRequest(arg1, MERGE_COLLECTION, new Object[] {
            arg2, arg3, listener4
        });
    }

    /** The method id used to dispatch {@link #restartGameIn} requests. */
    public static final int RESTART_GAME_IN = 14;

    // from interface WhirledGameService
    public void restartGameIn (Client arg1, int arg2, InvocationService.InvocationListener arg3)
    {
        ListenerMarshaller listener3 = new ListenerMarshaller();
        listener3.listener = arg3;
        sendRequest(arg1, RESTART_GAME_IN, new Object[] {
            Integer.valueOf(arg2), listener3
        });
    }

    /** The method id used to dispatch {@link #sendMessage} requests. */
    public static final int SEND_MESSAGE = 15;

    // from interface WhirledGameService
    public void sendMessage (Client arg1, String arg2, Object arg3, int arg4, InvocationService.InvocationListener arg5)
    {
        ListenerMarshaller listener5 = new ListenerMarshaller();
        listener5.listener = arg5;
        sendRequest(arg1, SEND_MESSAGE, new Object[] {
            arg2, arg3, Integer.valueOf(arg4), listener5
        });
    }

    /** The method id used to dispatch {@link #setCookie} requests. */
    public static final int SET_COOKIE = 16;

    // from interface WhirledGameService
    public void setCookie (Client arg1, byte[] arg2, InvocationService.InvocationListener arg3)
    {
        ListenerMarshaller listener3 = new ListenerMarshaller();
        listener3.listener = arg3;
        sendRequest(arg1, SET_COOKIE, new Object[] {
            arg2, listener3
        });
    }

    /** The method id used to dispatch {@link #setProperty} requests. */
    public static final int SET_PROPERTY = 17;

    // from interface WhirledGameService
    public void setProperty (Client arg1, String arg2, Object arg3, int arg4, boolean arg5, Object arg6, InvocationService.InvocationListener arg7)
    {
        ListenerMarshaller listener7 = new ListenerMarshaller();
        listener7.listener = arg7;
        sendRequest(arg1, SET_PROPERTY, new Object[] {
            arg2, arg3, Integer.valueOf(arg4), Boolean.valueOf(arg5), arg6, listener7
        });
    }

    /** The method id used to dispatch {@link #setTicker} requests. */
    public static final int SET_TICKER = 18;

    // from interface WhirledGameService
    public void setTicker (Client arg1, String arg2, int arg3, InvocationService.InvocationListener arg4)
    {
        ListenerMarshaller listener4 = new ListenerMarshaller();
        listener4.listener = arg4;
        sendRequest(arg1, SET_TICKER, new Object[] {
            arg2, Integer.valueOf(arg3), listener4
        });
    }
}
