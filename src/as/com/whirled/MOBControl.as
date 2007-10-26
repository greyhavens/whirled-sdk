//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled {

import flash.display.DisplayObject;

/**
 * Defines actions, accessors and callbacks available to all MOBs.
 */
public class MOBControl extends ActorControl
{
    /**
     * Creates a controller for a MOB. The display object is the MOB's visualization.
     */
    public function MOBControl (disp :DisplayObject)
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

    protected var _state :StateControl;
    protected var _quests :QuestControl;
}
}
