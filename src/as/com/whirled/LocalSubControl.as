//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled {

import com.threerings.ezgame.EZLocalSubControl;

/**
 * Provides access to the 'local' game services. Do not instantiate this class yourself,
 * access it via GameControl.local.
 */
public class LocalSubControl extends EZLocalSubControl
{
    public function LocalSubControl (parent :WhirledGameControl)
    {
        super(parent);
    }

    /**
     * Return the headshot image for the given occupant in the form of a Sprite object.
     *
     * The sprite are cached in the client backend so the user should not worry too much
     * about multiple requests for the same occupant.
     *
     * @param occupant the playerId to get the headshot for
     * @param callback signature: function (sprite :Sprite, success :Boolean) :void
     */
    public function getHeadShot (occupant :int, callback :Function) :void
    {
        callHostCode("getHeadShot_v1", occupant, callback);
    }

    /**
     * Set whether control bar buttons are shown.
     *
     * <b>Note:</b> this function changes local display only; other clients will not be affected.
     *
     * @param rematch sets whether the rematch button should be displayed automatically when
     *        the game is over.
     * @param backButtons sets whether the 'back to whirled' and 'back to lobby' buttons are
     *        showing.
     */
    public function setShowButtons (rematch :Boolean = true, backButtons :Boolean = true) :void
    {
        callHostCode("setShowButtons_v1", rematch, backButtons);
    }

    /**
     * Set a label to be shown above the occupants list in the game.
     * Set to null to remove the label.
     *
     * <b>Note:</b> this function changes local display only; other clients will not be affected.
     */
    public function setOccupantsLabel (label :String) :void
    {
        callHostCode("setOccupantsLabel_v1", label);
    }

    /**
     * Clear all the scores displayed in the occupants list.
     *
     * <b>Note:</b> this function changes local display only; other clients will not be affected.  
     *
     * @param clearValue a value to set all the scores to, or null to not show anything.
     * @param sortValuesToo if true, also clear the sort values, returning the list
     * to the default sort order.
     */
    public function clearScores (clearValue :Object = null, sortValuesToo :Boolean = false) :void
    {
        callHostCode("clearScores_v1", clearValue, sortValuesToo);
    }

    /**
     * Set scores for seated players.
     *
     * <b>Note:</b> this function changes local display only; other clients will not be affected.
     *
     * @param scores an array of 'score' values that must correspond to the seated players.
     * The scores may be numeric or String and will be displayed after the player names.
     * @param sortValues an array of sorting values that must correpond to the seated players.
     * If not specified then the scoreValues are used to sort the occupants list.
     */
    public function setPlayerScores (scores :Array, sortValues :Array = null) :void
    {
        callHostCode("setPlayerScores_v1", scores, sortValues);
    }

    /**
     * Set score or sortValue values for occupants. You may want to call clearScores prior
     * to using this method to ensure that occupants that you don't specify are cleared out.
     *
     * <b>Note:</b> this function changes local display only; other clients will not be affected.
     *
     * @param scores an Object mapping occupantId to a score value (which may be a String or
     * numeric), or to a two-dimensional array containing the score value and the sortValue.
     */
    public function setMappedScores (scores :Object) :void
    {
        callHostCode("setMappedScores_v1", scores);
    }

    /**
     * Instructs the game client to return to Whirled.
     */
    public function backToWhirled (showLobby :Boolean = false) :void
    {
        callHostCode("backToWhirled_v1", showLobby);
    }
}
}
