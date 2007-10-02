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
     * Ends the active game, declaring the specified players to be winners and losers and paying
     * out flow using the specified payout type (defined in WhirledGameControl.as).
     */
    public void endGameWithWinners (Client client, int[] winners, int[] losers, int payoutType,
                                    InvocationListener listener);

    /**
     * Ends the active game, using the supplied scores to determine the base payouts and new
     * ratings and paying out flow using the specified payout type (defined in
     * WhirledGameControl.as).
     */
    public void endGameWithScores (Client client, int[] playerIds, int[] scores, int payoutType,
                                   InvocationListener listener);

    /**
     * Awards the specified trophy to the specified player.
     */
    public void awardTrophy (Client client, String ident, int occupant,
                             InvocationListener listener);
}
