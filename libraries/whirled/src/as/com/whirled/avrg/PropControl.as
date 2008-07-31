//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg {

import flash.display.DisplayObject;

import com.whirled.FurniControl;

/**
 * Defines actions, accessors and callbacks available to all Props.
 */
public class PropControl extends FurniControl
{
    /**
     * Creates a controller for a Prop. The display object is the Prop's visualization.
     */
    public function PropControl (disp :DisplayObject)
    {
        super(disp);
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

    public function isGameActivated () :Boolean
    {
        return callHostCode("isGameActivated_v1") as Boolean;
    }

    public function activateGame () :Boolean
    {
        return callHostCode("activateGame_v1") as Boolean;
    }

    /** @private */
    override protected function createSubControls () :Array
    {
        return [
            _state = new StateControl(this),
            _quests = new QuestControl(this)
        ];
    }

    /** @private */
    protected var _state :StateControl;
    /** @private */
    protected var _quests :QuestControl;
}
}
