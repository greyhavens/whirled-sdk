//
// $Id$

package com.whirled.game {

import flash.events.Event;

/**
 * Dispatched on the 'net' subcontrol when a message is sent by any client.
 */
public class MessageReceivedEvent extends Event
{
    /**
     * The type of all MessageReceivedEvents.
     *
     * @eventType MsgReceived
     */
    public static const MESSAGE_RECEIVED :String = "MsgReceived";

    /**
     * Access the message name.
     */
    public function get name () :String
    {
        return _name;
    }

    /**
     * Access the message value.
     */
    public function get value () :Object
    {
        return _value;
    }

    /**
     * Access the id of the player that sent the message. For games with server-side code, a value 
     * of -1 means that the message was sent by the server.
     */
    public function get sender () :int
    {
        return _sender;
    }

    public function MessageReceivedEvent (messageName :String, value :Object, sender :int)
    {
        super(MESSAGE_RECEIVED);
        _name = messageName;
        _value = value;
        _sender = sender;
    }

    override public function toString () :String
    {
        return "[MessageReceivedEvent name=" + _name + ", value=" + _value + ", sender=" + _sender + "]";
    }

    override public function clone () :Event
    {
        return new MessageReceivedEvent(_name, _value, _sender);
    }

    /** @private */
    protected var _name :String;

    /** @private */
    protected var _value :Object;

    /** @private */
    protected var _sender :int;
}
}
