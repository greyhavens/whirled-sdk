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
 * Dispatched either when somebody in this room entered our current game, or somebody playing the
 * game entered this room. On the client, the event is only dispatched if the player entering the
 * room is not the local player. On the server agent, it is always dispatched.
 *
 * @eventType com.whirled.avrg.AVRGameRoomEvent.PLAYER_ENTERED
 */
[Event(name="playerEntered", type="com.whirled.avrg.AVRGameRoomEvent")]

/**
 * Dispatched either when somebody in this room left our current game, or somebody playing the game
 * left this room. On the client, the event is only dispatched if the player leaving the room is not
 * the local player. On the server agent, it is always dispatched.
 *
 * @eventType com.whirled.avrg.AVRGameRoomEvent.PLAYER_LEFT
 */
[Event(name="playerLeft", type="com.whirled.avrg.AVRGameRoomEvent")]

/**
 * Dispatched when a player in this room takes up a new location. The event is dispatched
 * immediately when the move is initiated, not when the avatar arrives at the location. The movement
 * itself may take a potentially long time.
 *
 * @eventType com.whirled.avrg.AVRGameRoomEvent.PLAYER_MOVED
 */
[Event(name="playerMoved", type="com.whirled.avrg.AVRGameRoomEvent")]

/**
 * Dispatched when something has changed about a player's avatar in this room.
 *
 * @eventType com.whirled.avrg.AVRGameRoomEvent.AVATAR_CHANGED
 */
[Event(name="avatarChanged", type="com.whirled.avrg.AVRGameRoomEvent")]

/**
 * Dispatched when a MOB has been created.
 *
 * @eventType com.whirled.avrg.AVRGameRoomEvent.MOB_CONTROL_AVAILABLE
 * @see http://wiki.whirled.com/Mobs
 * @see RoomSubControlServer#spawnMob()
 */
[Event(name="mobControlAvailable", type="com.whirled.avrg.AVRGameRoomEvent")]

/**
 * Dispatched when a signal has been received in this room.
 * @see com.whirled.EntityControl#sendSignal()
 */
[Event(name="signalReceived", type="com.whirled.avrg.AVRGameRoomEvent")]

/**
 * Provides AVR services for a single room to clients and server agents.
 */
public class RoomSubControlBase extends TargetedSubControl
{
    /** @private */
    public function RoomSubControlBase (ctrl :AbstractControl, targetId :int)
    {
        super(ctrl, targetId);
    }

    /**
     * Gets the id of this room. Room ids are the same as scene ids and are the same each time the
     * room is visited. They may also be used directly to access a scene
     * (www.whirled.com/#world-s{sceneId}).
     */
    public function getRoomId () :int
    {
        // subclasses take care of this
        return 0;
    }

    /**
     * Gets an array of the ids of all the players in this room.
     */
    public function getPlayerIds () :Array
    {
        return callHostCode("room_getPlayerIds_v1") as Array;
    }

    /**
     * Tests if a player of a given id is in this room.
     */
    public function isPlayerHere (id :int) :Boolean
    {
        return callHostCode("isPlayerHere_v1", id);
    }

    /**
     * Returns an array of <code>String</code>s corresponding to the ids of all the MOBs in this
     * room.
     * @see http://wiki.whirled.com/Mobs
     */
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

    /**
     * Gets all available information on the avatar of a player with the given id.
     * @throws Error if the player is not here
     */
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
        info.bounds = data[ix ++];
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
        mobId :String, ctrl :MobSubControlBase, delayEvent :Boolean) :void
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
        var control :MobSubControlBase = _mobControls[mobId];
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

