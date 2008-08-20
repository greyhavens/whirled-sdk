//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg {

import flash.events.Event;

import com.whirled.ControlEvent;

public class AVRGameControlEvent extends ControlEvent
{
    /** An event type dispatched when the control has been resized.
     * key: N/A
     * value: N/A
     *
     * @eventType sizeChanged
     */
    public static const SIZE_CHANGED :String = "sizeChanged";

    /**
     * Create a new AVRGameControlEvent.
     */
    public function AVRGameControlEvent (
        type :String, name :String = null, value :Object = null)
    {
        super(type, name, value);
    }

    override public function toString () :String
    {
        return "AVRGameControlEvent [type=" + type + ", name=" + _name + ", value=" + _value + "]";
    }

    // documentation inherited from Event
    override public function clone () :Event
    {
        return new AVRGameControlEvent(type, _name, _value);
    }
}
}
