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
 * Dispatched when we've entered our current room.
 *
 * @eventType com.whirled.avrg.AVRGamePlayerEvent.ENTERED_ROOM
 */
[Event(name="enteredRoom", type="com.whirled.avrg.AVRGamePlayerEvent")]

/**
 * Dispatched when we've left our current room.
 *
 * @eventType com.whirled.avrg.AVRGamePlayerEvent.LEFT_ROOM
 */
[Event(name="leftRoom", type="com.whirled.avrg.AVRGamePlayerEvent")]

/**
 * Dispatched when this player receives a coin payout.
 *
 * @eventType com.whirled.net.MessageReceivedEvent.COINS_AWARDED
 */
[Event(name="CoinsAwarded", type="com.whirled.avrg.AVRGamePlayerEvent")]

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
        return callHostCode("getPlayerId_v1");
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
            _parent, _targetId, "player_getGameData_v1", "player_setProperty_v1");
        return [ _props ];
    }

    /** @private */
    internal function coinsAwarded_v1 (amount :int) :void
    {
        dispatch(new AVRGamePlayerEvent(
                AVRGamePlayerEvent.COINS_AWARDED, _targetId, null, amount));
    }

    /** @private */
    internal function leftRoom_v1 () :void
    {
        dispatch(new AVRGamePlayerEvent(AVRGamePlayerEvent.LEFT_ROOM, _targetId));
    }

    /** @private */
    internal function enteredRoom_v1 (newScene :int) :void
    {
        dispatch(new AVRGamePlayerEvent(
                AVRGamePlayerEvent.ENTERED_ROOM, _targetId, null, newScene));
    }

    /** @private */
    protected var _props :PropertySubControlImpl;
}
}
