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

    /**
     * Configures this Whirled game with its service.
     */
    public void setWhirledGameService (WhirledGameMarshaller value);

    /**
     * Configures the game with the list of game data available to it.
     */
    public void setGameData (GameData[] value);

    /**
     * Adds ownership information for this game's data.
     */
    public void addToOwnershipData (Ownership elem);

    /**
     * Removes ownership information for this game's data.
     */
    public void removeFromOwnershipData (Comparable key);
}
