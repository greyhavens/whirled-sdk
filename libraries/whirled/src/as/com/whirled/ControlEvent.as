//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled {

import flash.events.Event;

/**
 * An Event dispatched on controls (AvatarControl, PetControl...) to indicate
 * that something has happened. Not all event types will be dispatched to all controls,
 * please see the documentation for those controls.
 */
public class ControlEvent extends Event
{
    /** An event type dispatched when an Actor has had its appearance
     * changed. Your code should react to this event and possibly redraw
     * the actor, taking into account the orientation and whether the
     * actor is moving or sleeping.
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

    /** An event type dispatched when a signal is received.
     * Dispatched only to the instance in control.
     * name: signal name
     * value: signal value
     *
     * @eventType signalReceived
     */
    public static const SIGNAL_RECEIVED :String = "signalRecieved";

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
     * @eventType controlAcquired
     */
    public static const CONTROL_ACQUIRED :String = "controlAcquired";

    /** An event type dispatched when the memory has changed.
     * name: memory name
     * value: memory value
     *
     * @eventType memoryChanged
     */
    public static const MEMORY_CHANGED :String = "memoryChanged";

    /** An event type dispatched to all entities when someone chats.
     * Note that only the instance in control receives this event.
     * name: the speaker's entity ID
     * value: chat message
     *
     * @eventType chatReceived
     */
    public static const CHAT_RECEIVED :String = "chatReceived";

    /** An event type dispatched to Furniture and Toys when the mouse is over them.
     * Note that the normal MouseEvents will be blocked if the furniture has an action,
     * so this is necessary to make doorways that react to mouse hovering.
     * name: unused
     * value: unused
     *
     * @eventType hoverOver
     */
    public static const HOVER_OVER :String = "hoverOver";

    /** An event type dispatched to Furniture and Toys when the mouse is leaves them.
     * Note that the normal MouseEvents will be blocked if the furniture has an action,
     * so this is necessary to make doorways that react to mouse hovering.
     * name: unused
     * value: unused
     *
     * @eventType hoverOut
     */
    public static const HOVER_OUT :String = "hoverOut";

    /**
     * An event dispatched when a new entity has been added to the room.
     * Note: only the instance in control receives this event.
     * name: The new entity ID
     * value: unused
     *
     * @eventType entityEntered
     */
    public static const ENTITY_ENTERED :String = "entityEntered";

    /**
     * An event dispatched when an entity has moved around within the room.
     * Note: only the instance in control receives this event.
     * name: The moving entity's ID
     * value: unused
     *
     * @eventType entityMoved
     */
    public static const ENTITY_MOVED :String = "entityMoved";

    /**
     * An event dispatched when an entity has been removed from the room.
     * Note: only the instance in control receives this event.
     * name: The entity ID. Note that this will no longer exist in the room.
     * value: unused
     *
     * @eventType entityLeft
     */
    public static const ENTITY_LEFT :String = "entityLeft";

    /**
     * Retrieve the event target, which will be the Control instance that
     * dispatched this event.
     */
    override public function get target () :Object
    {
        // We do nothing, so this could safely be removed, but it's here to
        // show that you can get the *Control you're using from each event.
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

    /** Internal storage for our name property. @private */
    protected var _name :String;

    /** Internal storage for our value property. @private */
    protected var _value :Object;
}
}
