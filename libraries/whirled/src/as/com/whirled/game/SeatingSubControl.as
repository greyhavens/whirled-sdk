//
// $Id$

package com.whirled.game {

/**
 * Access seating information for a seated game. Do not instantiate this class directly,
 * access it via GameControl.game.seating.
 */
// TODO: methods for allowing a player to pick a seat in SEATED_CONTINUOUS games.
public class SeatingSubControl extends AbstractSubControl
{
    /**
     * @private Constructed via GameControl.
     */
    public function SeatingSubControl (parent :GameControl, game :GameSubControl)
    {
        super(parent);
        _game = game;
    }

    /**
     * Get the player's position (seated index), or -1 if not a player.
     */
    public function getPlayerPosition (playerId :int) :int
    {
        return int(callHostCode("getPlayerPosition_v1", playerId));
    }

    /**
     * A convenient function to get our own player position,
     * or -1 if we're not a player.
     */
    public function getMyPosition () :int
    {
        return int(callHostCode("getMyPosition_v1"));
    }

    /**
     * Get all the players at the table, in their seated position.
     * Absent players will be represented by a 0.
     */
    public function getPlayerIds () :Array /* of playerId (int) */
    {
        return (callHostCode("getPlayers_v1") as Array);
    }

    /**
     * Get the names of the seated players, in the order of their seated position.
     */
    public function getPlayerNames () :Array /* of String */
    {
        return getPlayerIds().map(
            function (playerId :int, o2:*, o3:*) :String
            {
                return _game.getOccupantName(playerId);
            }
        );
    }

    /** Our direct parent. @private */
    protected var _game :GameSubControl;
}
}
