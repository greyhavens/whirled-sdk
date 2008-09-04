//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg {

import flash.geom.Rectangle;
import flash.utils.Dictionary;
import flash.utils.setTimeout;

import com.threerings.util.Log;

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

    public function getPlayerIds () :Array
    {
        return callHostCode("room_getPlayerIds_v1") as Array;
    }

    public function isPlayerHere (id :int) :Boolean
    {
        return callHostCode("isPlayerHere_v1", id);
    }

    public function getSpawnedMobs () :Array
    {
        var mobIds :Array = [];
        for (var id :String in _mobControls) {
            mobIds.push(id);
        }
        return mobIds;
    }

    /**
     * Get the room's bounds in pixel coordinates. This is essentially the width and height
     * of the room's decor. It is an absolute coordinate system, i.e. (x, y) for one client
     * here is the same (x, y) as for another.
     *
     * @return a Rectangle anchored at (0, 0)
     */
    public function getRoomBounds () :Rectangle
    {
        return callHostCode("getRoomBounds_v1") as Rectangle;
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

    /** @private */
    internal function setMobSubControl (
        mobId :String, ctrl :MobBaseSubControl, delayEvent :Boolean) :void
    {
        if (_mobControls[mobId] !== undefined) {
            Log.getLog(this).warning("Eek, overwriting mob control [mobId=" + mobId + "]");
        }
        _mobControls[mobId] = ctrl;
        ctrl.gotHostPropsFriend(_funcs);
        function doDisp () :void {
            dispatch(new AVRGameRoomEvent(
                AVRGameRoomEvent.MOB_CONTROL_AVAILABLE, _targetId, mobId, ctrl));
        }
        if (delayEvent) {
            setTimeout(doDisp, 0);
        } else {
            doDisp();
        }
    }

    /** @private */
    internal function mobRemoved_v1 (id :String) :void
    {
        Log.getLog(this).debug("Nuking mob control [id=" + id + "]");
        delete _mobControls[id];
    }

    /** @private */
    internal function mobAppearanceChanged_v1 (
        mobId :String, locArray :Array, orient :Number,
        moving :Boolean, idle :Boolean) :void
    {
        var control :MobBaseSubControl = _mobControls[mobId];
        if (control != null) {
            control.appearanceChanged(locArray, orient, moving, idle);
        }
    }

    /** @private */
    internal function callHostCodeFriend (name :String, ...args) :*
    {
        args.unshift(name);
        return callHostCode.apply(null, args);
    }

    /** @private */
    protected var _mobControls :Dictionary = new Dictionary();
}
}

