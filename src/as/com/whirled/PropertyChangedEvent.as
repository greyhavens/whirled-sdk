//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled {

import flash.events.Event;

public class PropertyChangedEvent extends Event
{
    /** An event type dispatched when a datum of game state has changed.
     * key: property key
     * value: property value
     *
     * @eventType propertyChanged
     */
    public static const PROPERTY_CHANGED :String = "propertyChanged";

    /**
     * Retrieve the event target, which will be the WhirledControl instance that
     * dispatched this event.
     */
    override public function get target () :Object
    {
        return super.target;
    }

    /**
     * Retrieve the key, a String, corresponding to the game state property that changed.
     */
    public function get key () :String
    {
        return _key;
    }

    /**
     * Retrieve the new value of the game state property that changed.
     */
    public function get value () :Object
    {
        return _value;
    }

    /**
     * Create a new PropertyChangedEvent
     */
    public function PropertyChangedEvent (key :String, value :Object)
    {
        super(PROPERTY_CHANGED);
        _key = key;
        _value = value;
    }

    override public function toString () :String
    {
        return "PropertyChangedEvent [key=" + _key + ", value=" + _value + "]";
    }

    // documentation inherited from Event
    override public function clone () :Event
    {
        return new PropertyChangedEvent(_key, _value);
    }

    /** Internal storage for our key property. */
    protected var _key :String;

    /** Internal storage for our value property. */
    protected var _value :Object;
}
}
