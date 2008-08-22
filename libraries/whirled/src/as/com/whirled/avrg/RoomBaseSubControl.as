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
 * @eventType com.whirled.avrg.AVRGameRoomEvent.PLAYER_ENTERED
 */
[Event(name="playerEntered", type="com.whirled.avrg.AVRGameRoomEvent")]

/**
 * Dispatched either when somebody in our room left our current game,
 * or somebody playing the game left our current room.
 *
 * @eventType com.whirled.avrg.AVRGameRoomEvent.PLAYER_LEFT
 */
[Event(name="playerLeft", type="com.whirled.avrg.AVRGameRoomEvent")]

/**
 * Dispatched when another player in our current room took up a new location.
 *
 * @eventType com.whirled.avrg.AVRGameRoomEvent.PLAYER_MOVED
 */
[Event(name="playerMoved", type="com.whirled.avrg.AVRGameRoomEvent")]

/**
 * Dispatched when something has changed about a player's
 * avatar.
 *
 * @eventType com.whirled.avrg.AVRGameRoomEvent.AVATAR_CHANGED
 */
[Event(name="avatarChanged", type="com.whirled.avrg.AVRGameRoomEvent")]

/**
 * Defines actions, accessors and callbacks available on the client only.
 */
public class RoomBaseSubControl extends TargetedSubControl
{
    /** @private */
    public function RoomBaseSubControl (ctrl :AbstractControl, targetId :int)
    {
        super(ctrl, targetId);
    }

    public function getRoomId () :int
    {
        return callHostCode("getRoomId_v1");
    }

    public function getPlayerIds () :Array
    {
        return callHostCode("room_getPlayerIds_v1") as Array;
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

    /** @private */
    internal function playerLeft_v1 (id :int) :void
    {
        dispatch(new AVRGameRoomEvent(AVRGameRoomEvent.PLAYER_LEFT, _targetId, null, id));
    }

    /** @private */
    internal function playerEntered_v1 (id :int) :void
    {
        dispatch(new AVRGameRoomEvent(AVRGameRoomEvent.PLAYER_ENTERED, _targetId, null, id));
    }

    /** @private */
    internal function playerMoved_v1 (id :int) :void
    {
        dispatch(new AVRGameRoomEvent(AVRGameRoomEvent.PLAYER_MOVED, _targetId, null, id));
    }

    /** @private */
    internal function actorAppearanceChanged_v1 (playerId :int) :void
    {
        dispatch(new AVRGameRoomEvent(
                AVRGameRoomEvent.AVATAR_CHANGED, _targetId, null, playerId));
    }

    /** @private */
    internal function actorStateSet_v1 (playerId :int, state :String) :void
    {
        dispatch(new AVRGameRoomEvent(
                AVRGameRoomEvent.AVATAR_CHANGED, _targetId, null, playerId));
    }
}
}
