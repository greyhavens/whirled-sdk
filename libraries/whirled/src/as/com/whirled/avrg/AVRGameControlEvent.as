//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg {

import flash.events.Event;

public class AVRGameControlEvent extends Event
{
    /**
     * An event type dispatched when somebody joined the AVRG.
     * key: N/A
     * value: the memberId of the player
     *
     * @eventType playerJoinedGame
     */
    public static const PLAYER_JOINED_GAME :String = "playerJoinedGame";

    /**
     * An event type dispatched when somebody left the AVRG.
     * key: N/A
     * value: the memberId of the player
     *
     * @eventType playerQuitGame
     */
    public static const PLAYER_QUIT_GAME :String = "playerQuitGame";

    /**
     * An event type dispatched when the control has been resized.
     * key: N/A
     * value: N/A
     *
     * @eventType sizeChanged
     */
    public static const SIZE_CHANGED :String = "sizeChanged";

    /**
     * An event type dispatched when a mob has changed appearance.
     * key: N/A
     * value: N/A
     *
     * @eventType mobAppearanceChanged
     */
    public static const MOB_APPEARANCE_CHANGED :String = "mobAppearanceChanged";

    /**
     * Retrieve the 'name' for this event, which is a String value
     * whose meaning is determined by the event type.
     */
    public function get name () :String
    {
        return _name;
    }

    /**
     * Retrieve the object 'value' for this event, which is a value
     * whose meaning is determined by the event type.
     */
    public function get value () :Object
    {
        return _value;
    }

    /**
     * Create a new AVRGameControlEvent.
     */
    public function AVRGameControlEvent (
        type :String, name :String = null, value :Object = null, cancelable :Boolean = false)
    {
        super(type, false, cancelable);

        _name = name;
        _value = value;
    }

    override public function toString () :String
    {
        return "AVRGameControlEvent [type=" + type + ", name=" + _name + ", value=" + _value +
            ", cancelable=" + cancelable + "]";
    }

    // documentation inherited from Event
    override public function clone () :Event
    {
        return new AVRGameControlEvent(type, _name, _value, cancelable);
    }

    /** Internal storage for our name property. @private */
    protected var _name :String;

    /** Internal storage for our value property. @private */
    protected var _value :Object;
}
}
