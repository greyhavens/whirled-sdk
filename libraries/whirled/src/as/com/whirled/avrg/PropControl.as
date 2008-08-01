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
     * Get the QuestSubControl, which contains methods for enumerating, offering, advancing,
     * cancelling and completing quests.
     */
    public function get quests () :QuestSubControl
    {
        return _quests;
    }

    /**
     * Get the StateSubControl, which contains methods for getting and setting properties
     * on AVRG's, both game-global and player-centric.
     */
    public function get state () :StateSubControl
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
            _state = new StateSubControl(this),
            _quests = new QuestSubControl(this)
        ];
    }

    /** @private */
    protected var _state :StateSubControl;
    /** @private */
    protected var _quests :QuestSubControl;
}
}
