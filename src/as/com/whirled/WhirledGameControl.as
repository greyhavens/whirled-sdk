//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled {

import flash.display.DisplayObject;
import flash.geom.Rectangle;

import com.threerings.ezgame.EZGameControl;

/**
 * Adds whirled-specific controls to EZGameControl
 */
public class WhirledGameControl extends EZGameControl
{
    /**
     * Creates a control and connects to the Whirled game system.
     *
     * @param disp the display object that is the game's UI.
     * @param autoReady if true, the game will automatically be started when initialization is
     * complete, if false, the game will not start until all clients call {@link #playerReady}.
     */
    public function WhirledGameControl (disp :DisplayObject, autoReady :Boolean = true)
    {
        super(disp, autoReady);
    }

    /**
     * Get the amount of flow that's <i>currently</i> available to award to the occupant who has
     * instantiated this game control.  In other words, your game is only responsible for granting
     * flow to the occupantId returned by getMyId(). You should grant flow based on the performance
     * in the game, but can also grant flow to non-players.
     */
    public function getAvailableFlow () :int
    {
        return int(callEZCode("getAvailableFlow_v1"));
    }

    /**
     * Award flow to this occupant. See {@link #getAvailableFlow}.
     */
    public function awardFlow (amount :int) :void
    {
        callEZCode("awardFlow_v1", amount);
    }

    /**
     * Enables or disables chat. When chat is disabled, it is not visible which is useful for games
     * in which the chat overlay obstructs the view during play.
     */
    public function setChatEnabled (enabled :Boolean) :void
    {
        callEZCode("setChatEnabled_v1", enabled);
    }

    /**
     * Relocates the chat overlay to the specified region. By default the overlay covers the entire
     * width of the display and the bottom 150 pixels or so.
     */
    public function setChatBounds (bounds :Rectangle) :void
    {
        callEZCode("setChatBounds_v1", bounds);
    }

    /**
     * Return the headshot image for the given occupant in the form of a Sprite object.
     *
     * The sprite are cached in the client backend so the user should not worry too much
     * about multiple requests for the same occupant.
     *
     * @param callback signature: function (sprite :Sprite, success :Boolean) :void
     */
    public function getHeadShot (occupant :int, callback :Function) :void
    {
        callEZCode("getHeadShot_v1", occupant, callback);
    }

    /**
     * Returns the bounds of the "stage" on which the game will be drawn. This is mainly useful for
     * the width and height so that the game can know how much area it has to cover, however the x
     * and y coordinates will also indicate the offset from the upper left of the stage of the view
     * rectangle that contains the game.
     *
     * TODO: the chat channel panel can be opened and closed during a game, so we need to dispatch
     * an event to let the game know in case it wants to do something special to handle that.
     */
    public function getStageBounds () :Rectangle
    {
        return Rectangle(callEZCode("getStageBounds_v1"));
    }
}
}
