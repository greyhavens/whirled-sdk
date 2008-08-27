//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg {

import flash.events.Event;

import com.whirled.avrg.AVRGameControlEvent;

/**
 * An event dispatched on a per-player AVRG sub control.
 */
public class AVRGameRoomEvent extends AVRGameControlEvent
{
    /**
     * An event type dispatched when a player entered a room.
     * key: N/A
     * value: the memberId of the player
     *
     * @eventType playerEntered
     */
    public static const PLAYER_ENTERED :String = "playerEntered";

    /**
     * An event type dispatched either when a player left a room.
     * key: N/A
     * value: the memberId of the player
     *
     * @eventType playerLeft
     */
    public static const PLAYER_LEFT :String = "playerLeft";

    /** An event type dispatched either when a player of our game who's also in our
     * current room took up a new location in the scene.
     * key: N/A
     * value: the memberId of the player
     *
     * @eventType playerLeft
     */
    public static const PLAYER_MOVED :String = "playerMoved";

    /** An event type dispatched when a something has changed about a player's avatar.
     * key: N/A
     * value: N/A
     *
     * @eventType avatarChanged
     */
    public static const AVATAR_CHANGED :String = "avatarChanged";

    /**
     * Create a new AVRGameRoomEvent.
     */
    public function AVRGameRoomEvent (
        type :String, roomId :int, name :String = null, value :Object = null)
    {
        super(type, name, value);
        _roomId = roomId;
    }

    public function get roomId () :int
    {
        return _roomId;
    }

    override public function toString () :String
    {
        return "AVRGameRoomEvent [type=" + type + ", roomId=" + roomId +
            ", name=" + _name + ", value=" + _value + "]";
    }

    // documentation inherited from Event
    override public function clone () :Event
    {
        return new AVRGameRoomEvent(type, _roomId, _name, _value);
    }

    protected var _roomId :int;
}
}
