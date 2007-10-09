//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.server;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationProvider;
import com.whirled.client.WhirledGameService;

/**
 * Defines the server-side of the {@link WhirledGameService}.
 */
public interface WhirledGameProvider extends InvocationProvider
{
    /**
     * Handles a {@link WhirledGameService#awardTrophy} request.
     */
    public void awardTrophy (ClientObject caller, String arg1, InvocationService.InvocationListener arg2)
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
}
