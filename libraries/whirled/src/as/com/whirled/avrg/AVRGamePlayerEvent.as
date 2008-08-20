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
public class AVRGamePlayerEvent extends AVRGameControlEvent
{
    /** An event type dispatched when the player receives some coins.
     * name: unused
     * value: the amount of coins awarded
     *
     * @eventType coinsAwarded
     */
    public static const COINS_AWARDED :String = "coinsAwarded";

    /** An event type dispatched when we've entered a new room.
     * key: N/A
     * value: the id of the scene we entered
     *
     * @eventType playerEntered
     */
    public static const ENTERED_ROOM :String = "enteredRoom";

    /** An event type dispatched when we leave our current room.
     * key: N/A
     * value: N/A
     *
     * @eventType playerLeft
     */
    public static const LEFT_ROOM :String = "leftRoom";

    /**
     * Create a new AVRGamePlayerEvent.
     */
    public function AVRGamePlayerEvent (
        type :String, playerId :int, name :String = null, value :Object = null)
    {
        super(type, name, value);
        _playerId = playerId;
    }

    public function get playerId () :int
    {
        return _playerId;
    }

    override public function toString () :String
    {
        return "AVRGamePlayerEvent [type=" + type + ", playerId=" + playerId +
            ", name=" + _name + ", value=" + _value + "]";
    }

    // documentation inherited from Event
    override public function clone () :Event
    {
        return new AVRGamePlayerEvent(type, _playerId, _name, _value);
    }

    protected var _playerId :int;
}
}
