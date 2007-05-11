//
// $Id$

package com.whirled.client;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService;

/**
 * Services available to Whirled games.
 */
public interface WhirledGameService extends InvocationService
{
    /**
     * Notes an award of the given amount of flow to the calling client. Awarded flow accumulates
     * server-side and is paid out when the game ends or when this client leaves the game. If the
     * amount exceeds the server-calculated cap, it is silently capped at that level.
     */
    public void awardFlow (Client client, int amount, InvocationListener listener);
}
