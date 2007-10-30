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

    /** An event type dispatched either when somebody in our room joined our current game,
     * or somebody playing the game entered our current room.
     * key: N/A
     * value: the oid of the player body
     *
     * @eventType playerEntered
     */
    public static const PLAYER_ENTERED :String = "playerEntered";

    /** An event type dispatched either when somebody in our room left our current game,
     * or somebody playing the game left our current room.
     * key: N/A
     * value: the oid of the player body
     *
     * @eventType playerLeft
     */
    public static const PLAYER_LEFT :String = "playerLeft";

    /** An event type dispatched either when a player of our game who's also in our
     * current room took up a new location in the scene.
     * key: N/A
     * value: the oid of the player body
     *
     * @eventType playerLeft
     */
    public static const PLAYER_MOVED :String = "playerMoved";

    /** An event type dispatched when we've entered a new room.
     * key: N/A
     * value: N/A
     *
     * @eventType playerEntered
     */
    public static const ENTERED_ROOM :String = "enteredRoom";

    /** An event type dispatched when we leave our current room.
     * key: N/A
     * value: N/A
     *
     * @eventType playerLeft
     */
    public static const LEFT_ROOM :String = "leftRoom";

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
