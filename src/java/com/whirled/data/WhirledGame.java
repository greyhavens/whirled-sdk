//
// $Id$

package com.whirled.data;

/**
 * Games that wish to make use of Whirled game services should have their {@link GameObject}
 * derivation implement this interface.
 */
public interface WhirledGame
{
    /** A message dispatched to each player's client object when flow is awarded. */
    public static final String FLOW_AWARDED_MESSAGE = "FlowAwarded";

    /**
     * Configures the {@link WhirledGameService} for this game.
     */
    public void setWhirledGameService (WhirledGameMarshaller whirledGameService);

    /**
     * Configures this game with the level packs available to it.
     */
    public void setLevelPacks (LevelInfo[] packs);

    /**
     * Configures this game with the item packs available to it.
     */
    public void setItemPacks (ItemInfo[] packs);
}
