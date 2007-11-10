//
// $Id$

package com.whirled.data;

import com.threerings.presents.dobj.DObject;

/**
 * Games that wish to make use of Whirled game services should have their {@link GameObject}
 * derivation implement this interface.
 */
public interface WhirledGame
{
    /** A message dispatched to each player's client object when flow is awarded. */
    public static final String FLOW_AWARDED_MESSAGE = "FlowAwarded";

    /** Cascading payout skews awards toward the winners by giving 50% of last place's payout to
     * first place, 25% to the next inner pair of opponents (third to second in a four player game,
     * for example), and so on. */
    public static final int CASCADING_PAYOUT = 0;

    /** Winner takes all splits the total flow available to award to all players in the game among
     * those identified as winners at the end of the game. */
    public static final int WINNERS_TAKE_ALL = 1;

    /** Each player receives a payout based only on their performance during the game and not
     * influenced by their relative ranking to one another. */
    public static int TO_EACH_THEIR_OWN = 2;

    /**
     * Configures this Whirled game with its service.
     */
    public void setWhirledGameService (WhirledGameMarshaller value);

    /**
     * Configures the game with the list of game data available to it.
     */
    public void setGameData (GameData[] value);
}
