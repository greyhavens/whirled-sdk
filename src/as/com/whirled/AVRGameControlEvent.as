//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled {

import flash.events.Event;

public class AVRGameControlEvent extends ControlEvent
{
    /** An event type dispatched when a datum of game state has changed.
     * key: property key
     * value: property value
     *
     * @eventType propertyChanged
     */
    public static const PROPERTY_CHANGED :String = "propertyChanged";

    /** An event type dispatched when a datum of player-local game state has changed.
     * key: property key
     * value: property value
     *
     * @eventType playerPropertyChanged
     */
    public static const PLAYER_PROPERTY_CHANGED :String = "playerPropertyChanged";

    /** An event type dispatched when a message is received.
     * key: message key
     * value: message value
     *
     * @eventType messageReceived
     */
    public static const MESSAGE_RECEIVED :String = "messageReceived";

    /** An event type dispatched when a quest was activated or deactivated for this player.
     * key: id of accepted quest
     * value: whether the quest was added (true) or removed (false) from our active quests
     *
     * @eventType questStateChanged
     */
    public static const QUEST_STATE_CHANGED :String = "questStateChanged";

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
