//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled {

import flash.display.DisplayObject;
import flash.geom.Rectangle;

/**
 * This file should be included by AVR games so that they can communicate
 * with the whirled.
 *
 * AVRGame means: Alternate Virtual Reality Game, and refers to games
 * played within the whirled environment.
 */
public class AVRGameControl extends WhirledControl
{
    /**
     * Create a world game interface. The display object is your world game.
     */
    public function AVRGameControl (disp :DisplayObject)
    {
        super(disp);
    }

    /**
     * Returns the bounds of the "stage" on which the AVRG will be drawn. This is the entire
     * area the AVRG can cover and includes potential empty space to the right of the room
     * view. See <code>getRoomBounds</code>. TODO: Implement RESIZE event.
     */
    public function getStageBounds () :Rectangle
    {
        return Rectangle(callHostCode("getStageBounds_v1"));
    }

    /**
     * Returns the bounds of our current room, or null in the unlikely case that we are
     * not in a room. Note that these bounds are likely to change every time the player
     * enters a different scene. TODO: Bring back movement events.
     */
    public function getRoomBounds () :Rectangle
    {
        return Rectangle(callHostCode("getRoomBounds_v1"));
    }

    /**
     * Get the QuestControl, which contains methods for enumerating, offering, advancing,
     * cancelling and completing quests.
     */
    public function get quests () :QuestControl
    {
        return _quests;
    }

    /**
     * Get the StateControl, which contains methods for getting and setting properties
     * on AVRG's, both game-global and player-centric.
     */
    public function get state () :StateControl
    {
        return _state;
    }

    public function deactivateGame () :Boolean
    {
        return callHostCode("deactivateGame_v1");
    }

    override protected function isAbstract () :Boolean
    {
        return false;
    }

    override protected function populateProperties (o :Object) :void
    {
        super.populateProperties(o);

        _state = new StateControl(this);
        _state.populateSubProperties(o);

        _quests = new QuestControl(this);
        _quests.populateSubProperties(o);
    }

    protected var _quests :QuestControl;
    protected var _state :StateControl;
}
}
