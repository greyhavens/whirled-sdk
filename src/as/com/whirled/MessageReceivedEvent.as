//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled {

import flash.events.Event;

public class MessageReceivedEvent extends Event
{
    /** An event type dispatched when a message is received.
     * key: message key
     * value: message value
     *
     * @eventType msgReceived
     */
    public static const MESSAGE_RECEIVED :String = "msgReceived";

    /**
     * Retrieve the key, a String, identifying the message received.
     */
    public function get key () :String
    {
        return _key;
    }

    /**
     * Retrieve the value associated with the transmitted message.
     */
    public function get value () :Object
    {
        return _value;
    }

    public function MessageReceivedEvent (key :String, value :Object)
    {
        super(MESSAGE_RECEIVED);
        _key = key;
        _value = value;
    }

    override public function toString () :String
    {
        return "MessageReceivedEvent [key=" + _key + ", value=" + _value + "]";
    }

    override public function clone () :Event
    {
        return new MessageReceivedEvent(_key, _value);
    }

    protected var _key :String;
    protected var _value :Object;
}
}
