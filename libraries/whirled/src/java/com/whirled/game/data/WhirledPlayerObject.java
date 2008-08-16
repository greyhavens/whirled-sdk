//
// $Id$

package com.whirled.game.data;

import com.threerings.crowd.data.BodyObject;
import com.threerings.crowd.data.OccupantInfo;
import com.threerings.crowd.data.PlaceObject;

/**
 * Body for playing whirled games.
 */
public class WhirledPlayerObject extends BodyObject
{
    /** Messages containing private inter-player messages begin with this. */
    public static final String PRIVATE_USER_MESSAGE_PREFIX = "Umsg:";
    
    /** 
     * Computes the name for private user messages for a given game id.
     */
    public static String getMessageName (int gameId)
    {
        return PRIVATE_USER_MESSAGE_PREFIX + gameId;
    }
    
    /**
     * Checks if a the name of a private user message is from the given game id.
     */
    public static boolean isFromGame (String eventName, int gameId)
    {
        return eventName.equals(getMessageName(gameId));
    }
    
    // from BodyObject
    @Override public OccupantInfo createOccupantInfo (PlaceObject plObj)
    {
        if (plObj instanceof WhirledGameObject) {
            return new WhirledGameOccupantInfo(this);

        } else {
            return super.createOccupantInfo(plObj);
        }
    }
}
