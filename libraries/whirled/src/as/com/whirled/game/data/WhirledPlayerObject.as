//
// $Id$

package com.whirled.game.data {

import com.threerings.crowd.data.BodyObject;

/**
 * Body for playing whirled games.
 */
public class WhirledPlayerObject extends BodyObject
{
    /** Messages containing private inter-player messages begin with this. */
    public static const PRIVATE_USER_MESSAGE_PREFIX :String  = "Umsg:";
    
    /** 
     * Computes the name for private user messages for a given game id.
     */
    public static function getMessageName (gameId :int) :String
    {
        return PRIVATE_USER_MESSAGE_PREFIX + gameId;
    }
    
    /**
     * Checks if a the name of a private user message is from the given game id.
     */
    public static function isFromGame (eventName :String, gameId :int) :Boolean
    {
        return eventName == getMessageName(gameId);
    }
    
}

}
