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
 * Dispatched when this player completes a task and receives a coin payout.
 *
 * @eventType com.whirled.net.MessageReceivedEvent.TASK_COMPLETE
 */
[Event(name="taskCompleted", type="com.whirled.avrg.AVRGamePlayerEvent")]

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

    public function getRoomId () :int
    {
        return callHostCode("player_getRoomId_v1") as int;
    }

    public function deactivateGame () :void
    {
        callHostCode("deactivateGame_v1");
    }

    /**
     * Returns all item packs owned by this client's player (the default) or a specified player.
     * The packs are returned as an array of objects with the following properties:
     *
     * <pre>
     * ident - string identifier of item pack
     * name - human readable name of item pack
     * mediaURL - URL for item pack content
     * </pre>
     */
    public function getPlayerItemPacks () :Array
    {
        return (callHostCode("getPlayerItemPacks_v1") as Array);
    }

    /**
     * Returns all level packs owned by this client's player (the default) or a specified player.
     * The packs are returned as an array of objects with the following properties:
     *
     * <pre>
     * ident - string identifier of item pack
     * name - human readable name of item pack
     * mediaURL - URL for item pack content
     * premium - boolean indicating that content is premium or not
     * </pre>
     */
    public function getPlayerLevelPacks () :Array
    {
        return (callHostCode("getPlayerLevelPacks_v1") as Array);
    }

    /**
     * Returns true if this client's player (the default) or a specified player has the trophy
     * with the specified identifier.
     */
    public function holdsTrophy (ident :String) :Boolean
    {
        return (callHostCode("holdsTrophy_v1", ident) as Boolean);
    }

    public function completeTask (taskId :String, payout :Number) :void
    {
        callHostCode("completeTask_v1", taskId, payout);
    }

    public function playAvatarAction (action :String) :void
    {
        callHostCode("playAvatarAction_v1", action);
    }

    public function setAvatarState (state :String) :void
    {
        callHostCode("setAvatarState_v1", state);
    }

    public function setAvatarMoveSpeed (pixelsPerSecond :Number) :void
    {
        callHostCode("setAvatarMoveSpeed_v1", pixelsPerSecond);
    }

    public function setAvatarLocation (x :Number, y :Number, z: Number, orient :Number) :void
    {
        callHostCode("setAvatarLocation_v1", x, y, z, orient);
    }

    public function setAvatarOrientation (orient :Number) :void
    {
        callHostCode("setAvatarOrientation_v1", orient);
    }

    /** @private */
    override protected function createSubControls () :Array
    {
        _props = new PropertySubControlImpl(
            _parent, _targetId, "player_getGameData_v1", "player_setProperty_v1");
        return [ _props ];
    }

    /** @private */
    internal function taskCompleted_v1 (task :String, amount :int) :void
    {
        dispatch(new AVRGamePlayerEvent(
                AVRGamePlayerEvent.TASK_COMPLETED, _targetId, task, amount));
    }

    /** @private */
    internal function leftRoom_v1 (scene :int) :void
    {
        dispatch(new AVRGamePlayerEvent(AVRGamePlayerEvent.LEFT_ROOM, _targetId, null, scene));
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
