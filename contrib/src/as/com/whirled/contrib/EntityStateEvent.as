package com.whirled.contrib {

import flash.events.Event;

public class EntityStateEvent extends Event
{
    public static const STATE_CHANGED :String = "entityStateChanged";

    /**
     * Retrieve the 'name' for this event, which is a String whose meaning is determined
     * by the event type.
     */
    public function get name () :String
    {
        return _name;
    }

    /**
     * Retrieve the 'value' for this event, which is an Object whose meaning is determined
     * by the event type.
     */
    public function get value () :Object
    {
        return _value;
    }

    public function EntityStateEvent (type :String, name :String, value :Object)
    {
        super(type);

        _name = name;
        _value = value;
    }

    override public function clone () :Event
    {
        return new EntityStateEvent(type, _name, _value);
    }

    protected var _name :String;
    protected var _value :Object;
}
}
