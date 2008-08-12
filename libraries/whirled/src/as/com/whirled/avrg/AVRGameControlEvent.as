//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg {

import flash.events.Event;

import com.whirled.ControlEvent;

public class AVRGameControlEvent extends ControlEvent
{
    /** An event type dispatched when the player receives some coins.
     * name: unused
     * value: the amount of coins awarded
     *
     * @eventType coinsAwarded
     */
    public static const COINS_AWARDED :String = "coinsAwarded";

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
     * value: the id of the scene we entered
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

    /** An event type dispatched when a something has changed about a player's avatar.
     * key: N/A
     * value: N/A
     *
     * @eventType avatarChanged
     */
    public static const AVATAR_CHANGED :String = "avatarChanged";

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
