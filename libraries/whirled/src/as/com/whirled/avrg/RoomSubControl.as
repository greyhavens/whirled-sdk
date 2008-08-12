//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg {

import com.whirled.AbstractControl;
import com.whirled.AbstractSubControl;

import com.whirled.TargetedSubControl;
import com.whirled.net.PropertyGetSubControl;
import com.whirled.net.impl.PropertyGetSubControlImpl;

/**
 * Dispatched either when somebody in our room entered our current game,
 * or somebody playing the game entered our current room.
 *
 * @eventType com.whirled.avrg.AVRGameControlEvent.PLAYER_ENTERED
 */
[Event(name="playerEntered", type="com.whirled.avrg.AVRGameControlEvent")]

/**
 * Dispatched either when somebody in our room left our current game,
 * or somebody playing the game left our current room.
 *
 * @eventType com.whirled.avrg.AVRGameControlEvent.PLAYER_LEFT
 */
[Event(name="playerLeft", type="com.whirled.avrg.AVRGameControlEvent")]

/**
 * Dispatched when another player in our current room took up a new location.
 *
 * @eventType com.whirled.avrg.AVRGameControlEvent.PLAYER_MOVED
 */
[Event(name="playerMoved", type="com.whirled.avrg.AVRGameControlEvent")]

/**
 * Dispatched when we've entered our current room.
 *
 * @eventType com.whirled.avrg.AVRGameControlEvent.ENTERED_ROOM
 */
[Event(name="enteredRoom", type="com.whirled.avrg.AVRGameControlEvent")]

/**
 * Dispatched when we've left our current room.
 *
 * @eventType com.whirled.avrg.AVRGameControlEvent.LEFT_ROOM
 */
[Event(name="leftRoom", type="com.whirled.avrg.AVRGameControlEvent")]

/**
 * Dispatched when something has changed about a player's
 * avatar.
 *
 * @eventType com.whirled.avrg.AVRGameControlEvent.AVATAR_CHANGED
 */
[Event(name="avatarChanged", type="com.whirled.avrg.AVRGameControlEvent")]

/**
 * Defines actions, accessors and callbacks available on the client only.
 */
public class RoomSubControl extends TargetedSubControl
{
    /** @private */
    public function RoomSubControl (ctrl :AbstractControl, targetId :int = 0)
    {
        super(ctrl, targetId);
    }

    public function get props () :PropertyGetSubControl
    {
        return _props;
    }

    public function getRoomId () :int
    {
        return callHostCode("getRoomId_v1") as int;
    }

    public function getPlayerIds () :Array
    {
        return callHostCode("getRoomPlayerIds_v1") as Array;
    }

    public function isPlayerHere (id :int) :Boolean
    {
        return callHostCode("isPlayerHere_v1", id);
    }

    public function getAvatarInfo (playerId :int) :AVRGameAvatar
    {
        var data :Array = callHostCode("getAvatarInfo_v1", playerId);
        if (data == null) {
            return null;
        }
        var ix :int = 0;
        var info :AVRGameAvatar = new AVRGameAvatar();
        info.name = data[ix ++];
        info.state = data[ix ++];
        info.x = data[ix ++];
        info.y = data[ix ++];
        info.z = data[ix ++];
        info.orientation = data[ix ++];
        info.moveSpeed = data[ix ++];
        info.isMoving = data[ix ++];
        info.isIdle = data[ix ++];
        info.stageBounds = data[ix ++];
        return info;
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
    override protected function setUserProps (o :Object) :void
    {
        super.setUserProps(o);

        o["playerLeft_v1"] = playerLeft_v1;
        o["playerEntered_v1"] = playerEntered_v1;
        o["leftRoom_v1"] = leftRoom_v1;
        o["enteredRoom_v1"] = enteredRoom_v1;

        o["actorStateSet_v1"] = actorStateSet_v1;
        o["actorAppearanceChanged_v1"] = actorAppearanceChanged_v1;
    }

    /** @private */
    override protected function createSubControls () :Array
    {
        _props = new PropertyGetSubControlImpl(
            _parent, _targetId, "room_propertyWasSet", "room_getGameData");
        return [ _props ];
    }

    /** @private */
    protected function playerLeft_v1 (id :int) :void
    {
        dispatch(new AVRGameControlEvent(AVRGameControlEvent.PLAYER_LEFT, null, id));
    }

    /** @private */
    protected function playerEntered_v1 (id :int) :void
    {
        dispatch(new AVRGameControlEvent(AVRGameControlEvent.PLAYER_ENTERED, null, id));
    }

    /** @private */
    protected function playerMoved_v1 (id :int) :void
    {
        dispatch(new AVRGameControlEvent(AVRGameControlEvent.PLAYER_MOVED, null, id));
    }

    /** @private */
    protected function leftRoom_v1 () :void
    {
        dispatch(new AVRGameControlEvent(AVRGameControlEvent.LEFT_ROOM));
    }

    /** @private */
    protected function enteredRoom_v1 (newScene :int) :void
    {
        dispatch(new AVRGameControlEvent(AVRGameControlEvent.ENTERED_ROOM, null, newScene));
    }

    /** @private */
    protected function actorAppearanceChanged_v1 (playerId :int) :void
    {
        dispatch(new AVRGameControlEvent(AVRGameControlEvent.AVATAR_CHANGED, null, playerId));
    }

    /** @private */
    protected function actorStateSet_v1 (playerId :int, state :String) :void
    {
        dispatch(new AVRGameControlEvent(AVRGameControlEvent.AVATAR_CHANGED, null, playerId));
    }

    protected var _props :PropertyGetSubControl;
}
}
