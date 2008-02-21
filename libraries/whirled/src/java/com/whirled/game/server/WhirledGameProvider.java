//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.server;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationProvider;
import com.whirled.game.client.WhirledGameService;

/**
 * Defines the server-side of the {@link WhirledGameService}.
 */
public interface WhirledGameProvider extends InvocationProvider
{
    /**
     * Handles a {@link WhirledGameService#addToCollection} request.
     */
    public void addToCollection (ClientObject caller, String arg1, byte[][] arg2, boolean arg3, InvocationService.InvocationListener arg4)
        throws InvocationException;

    /**
     * Handles a {@link WhirledGameService#awardPrize} request.
     */
    public void awardPrize (ClientObject caller, String arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;

    /**
     * Handles a {@link WhirledGameService#awardTrophy} request.
     */
    public void awardTrophy (ClientObject caller, String arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;

    /**
     * Handles a {@link WhirledGameService#checkDictionaryWord} request.
     */
    public void checkDictionaryWord (ClientObject caller, String arg1, String arg2, String arg3, InvocationService.ResultListener arg4)
        throws InvocationException;

    /**
     * Handles a {@link WhirledGameService#endGame} request.
     */
    public void endGame (ClientObject caller, int[] arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;

    /**
     * Handles a {@link WhirledGameService#endGameWithScores} request.
     */
    public void endGameWithScores (ClientObject caller, int[] arg1, int[] arg2, int arg3, InvocationService.InvocationListener arg4)
        throws InvocationException;

    /**
     * Handles a {@link WhirledGameService#endGameWithWinners} request.
     */
    public void endGameWithWinners (ClientObject caller, int[] arg1, int[] arg2, int arg3, InvocationService.InvocationListener arg4)
        throws InvocationException;

    /**
     * Handles a {@link WhirledGameService#endRound} request.
     */
    public void endRound (ClientObject caller, int arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;

    /**
     * Handles a {@link WhirledGameService#endTurn} request.
     */
    public void endTurn (ClientObject caller, int arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;

    /**
     * Handles a {@link WhirledGameService#getCookie} request.
     */
    public void getCookie (ClientObject caller, int arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;

    /**
     * Handles a {@link WhirledGameService#getDictionaryLetterSet} request.
     */
    public void getDictionaryLetterSet (ClientObject caller, String arg1, String arg2, int arg3, InvocationService.ResultListener arg4)
        throws InvocationException;

    /**
     * Handles a {@link WhirledGameService#getFromCollection} request.
     */
    public void getFromCollection (ClientObject caller, String arg1, boolean arg2, int arg3, String arg4, int arg5, InvocationService.ConfirmListener arg6)
        throws InvocationException;

    /**
     * Handles a {@link WhirledGameService#mergeCollection} request.
     */
    public void mergeCollection (ClientObject caller, String arg1, String arg2, InvocationService.InvocationListener arg3)
        throws InvocationException;

    /**
     * Handles a {@link WhirledGameService#restartGameIn} request.
     */
    public void restartGameIn (ClientObject caller, int arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;

    /**
     * Handles a {@link WhirledGameService#sendMessage} request.
     */
    public void sendMessage (ClientObject caller, String arg1, Object arg2, int arg3, InvocationService.InvocationListener arg4)
        throws InvocationException;

    /**
     * Handles a {@link WhirledGameService#setCookie} request.
     */
    public void setCookie (ClientObject caller, byte[] arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;

    /**
     * Handles a {@link WhirledGameService#setProperty} request.
     */
    public void setProperty (ClientObject caller, String arg1, Object arg2, Integer arg3, boolean arg4, boolean arg5, Object arg6, InvocationService.InvocationListener arg7)
        throws InvocationException;

    /**
     * Handles a {@link WhirledGameService#setTicker} request.
     */
    public void setTicker (ClientObject caller, String arg1, int arg2, InvocationService.InvocationListener arg3)
        throws InvocationException;
}
