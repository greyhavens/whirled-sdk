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
 * Dispatched when this player has just entered a room (or was already in the room and just started
 * playing the game).
 *
 * @eventType com.whirled.avrg.AVRGamePlayerEvent.ENTERED_ROOM
 * @see com.whirled.avrg.GameSubControlServer#event:playerJoinedGame
 */
[Event(name="enteredRoom", type="com.whirled.avrg.AVRGamePlayerEvent")]

/**
 * Dispatched when this player has left a room (or has chosen to leave the game).
 *
 * @eventType com.whirled.avrg.AVRGamePlayerEvent.LEFT_ROOM
 * @see com.whirled.avrg.GameSubControlServer#event:playerQuitGame
 */
[Event(name="leftRoom", type="com.whirled.avrg.AVRGamePlayerEvent")]


/**
 * Dispatched when this player completes a task and receives a coin payout.
 *
 * @eventType com.whirled.avrg.AVRGamePlayerEvent.TASK_COMPLETED
 * @see #completeTask()
 */
[Event(name="taskCompleted", type="com.whirled.avrg.AVRGamePlayerEvent")]

/**
 * Provides services for a single player of an AVRG to the server agent and client.
 */
public class PlayerSubControlBase extends TargetedSubControl
{
    /** @private */
    public function PlayerSubControlBase (ctrl :AbstractControl, targetId :int = 0)
    {
        super(ctrl, targetId);
    }

    /**
     * Accesses the read-write properties of this player. Properties may be persisted and will be
     * restored when the player rejoins the game. Persistent properties should only be used when
     * genuinely necessary. Persisting properties on a guest player will have no effect.
     * @see com.whirled.net.NetConstants#makePersistent()
     */
    public function get props () :PropertySubControl
    {
        return _props;
    }

    /**
     * Gets the id of this player. For joined members, this id is the member id and can be used to
     * view the member's profile (www.whirled.com/#people-{id}).
     */
    public function getPlayerId () :int
    {
        // subclasses take care of this
        return 0;
    }

    /**
     * Accesses the id of the room that this player is in.
     */
    public function getRoomId () :int
    {
        return callHostCode("player_getRoomId_v1") as int;
    }

    /**
     * Quits the game for this player. This method should be called for example when the user
     * closes the HUD of a game.
     */
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

    /**
     * Marks this player as having achieved a task. The server will process this information and
     * generate a coin payout based on a number of factors, including how long it takes players
     * on average to complete the task. Games should call this after a milestone is reached such as
     * completion of a level. The task id is arbitrary and is only used for record keeping.
     * @see #event:taskCompleted
     */
    // TODO: can we be more exact on the use of taskId?
    public function completeTask (taskId :String, payout :Number) :void
    {
        callHostCode("completeTask_v1", taskId, payout);
    }

    /**
     * Plays an action on this players avatar.
     * @see com.whirled.AvatarControl#event:actionTriggered
     */
    public function playAvatarAction (action :String) :void
    {
        callHostCode("playAvatarAction_v1", action);
    }

    /**
     * Sets the stats of this player's avatar.
     * @see com.whirled.ActorControl#event:stateChanged
     */
    public function setAvatarState (state :String) :void
    {
        callHostCode("setAvatarState_v1", state);
    }

    /**
     * Sets the move speed of this player's avatar. TODO: implement and unmark private
     * @private
     */
    public function setAvatarMoveSpeed (pixelsPerSecond :Number) :void
    {
        callHostCode("setAvatarMoveSpeed_v1", pixelsPerSecond);
    }

    /**
     * Sets the location and orientation of this player's avatar in room coordinates.
     * @see http://wiki.whirled.com/Coordinate_systems
     */
    public function setAvatarLocation (x :Number, y :Number, z: Number, orient :Number) :void
    {
        callHostCode("setAvatarLocation_v1", x, y, z, orient);
    }

    /**
     * Sets the orientation of this player's avatar. TODO: implement and unmark private
     * @private
     */
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
    internal function taskCompleted_v1 (task :String, amount :int) :Boolean
    {
        var evt :AVRGamePlayerEvent = new AVRGamePlayerEvent(
            AVRGamePlayerEvent.TASK_COMPLETED, _targetId, task, amount, true);
        dispatch(evt);
        return evt.isDefaultPrevented();
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
