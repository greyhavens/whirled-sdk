//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled {

import flash.events.Event;

public class ControlEvent extends Event
{
    /** An event type dispatched when an Actor has had its appearance
     * changed. Your code should react to this event and possibly redraw
     * the actor, taking into account the orientation and whether the
     * actor is moving.
     * name: unused
     * value: unused
     *
     * @eventType appearanceChanged
     */
    public static const APPEARANCE_CHANGED :String = "appearanceChanged";

    /** An event type dispatched when a message is received.
     * name: message name
     * value: message value
     *
     * @eventType messageReceived
     */
    public static const MESSAGE_RECEIVED :String = "messageRecieved";

    /** An event type dispatched when an action is triggered.
     * name: action name 
     * value: action value
     *
     * @eventType actionTriggered
     */
    public static const ACTION_TRIGGERED :String = "actionTriggered";

    /** An event type dispatched to actors to indicate that they should
     * be in the specified state.
     * name: state name
     * value: unused
     *
     * @eventType stateChanged
     */
    public static const STATE_CHANGED :String = "stateChanged";

    /** An event type dispatched when this avatar speaks.
     * name: unused
     * value: unused
     *
     * @eventType avatarSpoke
     */
    public static const AVATAR_SPOKE :String = "avatarSpoke";

    /** An event type dispatched when this client-side instance of the item
     * has gained "control" over the other client-side instances.
     * name: unused
     * value: unused
     *
     * @eventType gotControl
     */
    public static const GOT_CONTROL :String = "gotControl";

    /** An event type dispatched when the memory has changed.
     * name: memory name
     * value: memory value
     *
     * @eventType memoryChanged
     */
    public static const MEMORY_CHANGED :String = "memoryChanged";

    /** An event type dispatched to pets, when they overhear chatter in the room.
     * name: speaker name
     * value: chat message
     *
     * @eventType gotChat
     */
    public static const RECEIVED_CHAT :String = "receivedChat";
    
    /**
     * Retrieve the event target, which will be the WhirledControl instance that
     * dispatched this event.
     */
    override public function get target () :Object
    {
        return super.target;
    }

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
     * Create a new ControlEvent.
     */
    public function ControlEvent (
        type :String, name :String = null, value :Object = null)
    {
        super(type);
        _name = name;
        _value = value;
    }

    override public function toString () :String
    {
        return "ControlEvent [type=" + type + ", name=" + _name + ", value=" + _value + "]";
    }

    // documentation inherited from Event
    override public function clone () :Event
    {
        return new ControlEvent(type, _name, _value);
    }

    /** Internal storage for our name property. */
    protected var _name :String;

    /** Internal storage for our value property. */
    protected var _value :Object;
}
}
