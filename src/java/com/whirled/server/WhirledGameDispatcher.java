//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.server;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.data.InvocationMarshaller;
import com.threerings.presents.server.InvocationDispatcher;
import com.threerings.presents.server.InvocationException;
import com.whirled.client.WhirledGameService;
import com.whirled.data.WhirledGameMarshaller;

/**
 * Dispatches requests to the {@link WhirledGameProvider}.
 */
public class WhirledGameDispatcher extends InvocationDispatcher
{
    /**
     * Creates a dispatcher that may be registered to dispatch invocation
     * service requests for the specified provider.
     */
    public WhirledGameDispatcher (WhirledGameProvider provider)
    {
        this.provider = provider;
    }

    // from InvocationDispatcher
    public InvocationMarshaller createMarshaller ()
    {
        return new WhirledGameMarshaller();
    }

    @SuppressWarnings("unchecked") // from InvocationDispatcher
    public void dispatchRequest (
        ClientObject source, int methodId, Object[] args)
        throws InvocationException
    {
        switch (methodId) {
        case WhirledGameMarshaller.AWARD_TROPHY:
            ((WhirledGameProvider)provider).awardTrophy(
                source,
                (String)args[0], ((Integer)args[1]).intValue(), (InvocationService.InvocationListener)args[2]
            );
            return;

        case WhirledGameMarshaller.END_GAME_WITH_SCORES:
            ((WhirledGameProvider)provider).endGameWithScores(
                source,
                (int[])args[0], (int[])args[1], ((Integer)args[2]).intValue(), (InvocationService.InvocationListener)args[3]
            );
            return;

        case WhirledGameMarshaller.END_GAME_WITH_WINNERS:
            ((WhirledGameProvider)provider).endGameWithWinners(
                source,
                (int[])args[0], (int[])args[1], ((Integer)args[2]).intValue(), (InvocationService.InvocationListener)args[3]
            );
            return;

        default:
            super.dispatchRequest(source, methodId, args);
            return;
        }
    }
}
