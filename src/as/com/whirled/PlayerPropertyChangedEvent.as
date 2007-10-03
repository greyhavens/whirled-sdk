//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled {

import flash.events.Event;

public class PlayerPropertyChangedEvent extends PropertyChangedEvent
{
    /** An event type dispatched when a datum of player-local game state has changed.
     * key: property key
     * value: property value
     *
     * @eventType playerPropertyChanged
     */
    public static const PLAYER_PROPERTY_CHANGED :String = "playerPropertyChanged";

    /**
     * Create a new PlayerPropertyChangedEvent
     */
    public function PlayerPropertyChangedEvent (key :String, value :Object)
    {
        super(key, value);
    }

    override public function toString () :String
    {
        return "PlayerPropertyChangedEvent [key=" + _key + ", value=" + _value + "]";
    }

    // documentation inherited from Event
    override public function clone () :Event
    {
        return new PlayerPropertyChangedEvent(_key, _value);
    }
}
}
