//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg {

import com.whirled.AbstractControl;
import com.whirled.TargetedSubControl;
import com.whirled.net.PropertySubControl;
import com.whirled.net.impl.PropertySubControlImpl;

/**
 * Dispatched when this player receives a coin payout.
 *
 * @eventType com.whirled.net.MessageReceivedEvent.COINS_AWARDED
 */
[Event(name="CoinsAwarded", type="com.whirled.avrg.AVRGameControlEvent")]

/**
 */
public class PlayerBaseSubControl extends TargetedSubControl
{
    /** @private */
    public function PlayerBaseSubControl (ctrl :AbstractControl, targetId :int = 0)
    {
        super(ctrl, targetId);
    }

    public function get props () :PropertySubControl
    {
        return _props;
    }

    public function getPlayerId () :int
    {
        return _targetId;
    }

    public function getRoomId () :int
    {
        return callHostCode("getRoomId_v1") as int;
    }

    public function deactivateGame () :Boolean
    {
        return callHostCode("deactivateGame_v1");
    }

    public function completeTask (taskId :String, payout :Number) :Boolean
    {
        return callHostCode("completeTask_v1", taskId, payout);
    }

    public function playAvatarAction (action :String) :Boolean
    {
        return callHostCode("playAvatarAction_v1", action);
    }

    public function setAvatarState (state :String) :Boolean
    {
        return callHostCode("setAvatarState_v1", state);
    }

    public function setAvatarMoveSpeed (pixelsPerSecond :Number) :Boolean
    {
        return callHostCode("setAvatarMoveSpeed_v1", pixelsPerSecond);
    }

    public function setAvatarLocation (x :Number, y :Number, z: Number, orient :Number) :Boolean
    {
        return callHostCode("setAvatarLocation_v1", x, y, z, orient);
    }

    public function setAvatarOrientation (orient :Number) :Boolean
    {
        return callHostCode("setAvatarOrientation_v1", orient);
    }

    /** @private */
    override protected function createSubControls () :Array
    {
        _props = new PropertySubControlImpl(
            _parent, _targetId, "player_propertyWasSet_v1",
            "player_getGameData_v1", "player_setProperty_v1");
        return [ _props ];
    }

    /** @private */
    internal function coinsAwarded_v1 (amount :int) :void
    {
        // TODO: targetId
        dispatch(new AVRGameControlEvent(AVRGameControlEvent.COINS_AWARDED, null, amount));
    }

    /** @private */
    protected var _props :PropertySubControl;
}
}
