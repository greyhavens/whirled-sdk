//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg {

import com.whirled.AbstractControl;
import com.whirled.AbstractSubControl;

/**
 * Dispatched when a game-global state property has changed.
 * 
 * @eventType com.whirled.avrg.AVRGameControlEvent.PROPERTY_CHANGED
 */
[Event(name="propertyChanged", type="com.whirled.avrg.AVRGameControlEvent")]

/**
 * Dispatched when a player-local state property has changed.
 * 
 * @eventType com.whirled.avrg.AVRGameControlEvent.PLAYER_PROPERTY_CHANGED
 */
[Event(name="playerPropertyChanged", type="com.whirled.avrg.AVRGameControlEvent")]

/**
 * Dispatched when a message has been received.
 * 
 * @eventType com.whirled.avrg.AVRGameControlEvent.MESSAGE_RECEIVED
 */
[Event(name="messageReceived", type="com.whirled.avrg.AVRGameControlEvent")]

public class StateSubControl extends AbstractSubControl
{
    /** @private */
    public function StateSubControl (ctrl :AbstractControl)
    {
        super(ctrl)
    }

    public function getProperty (key :String) :Object
    {
        return callHostCode("getProperty_v1", key);
    }

    public function getProperties () :Object
    {
        return callHostCode("getProperties_v1");
    }

    public function setProperty (key :String, value :Object, persistent :Boolean) :Boolean
    {
        return callHostCode("setProperty_v1", key, value, persistent);
    }

    public function getRoomProperty (key :String) :Object
    {
        return callHostCode("getRoomProperty_v1", key);
    }

    public function setRoomProperty (key :String, value :Object) :Boolean
    {
        return callHostCode("setRoomProperty_v1", key, value);
    }

    public function getRoomProperties () :Object
    {
        return callHostCode("getRoomProperties_v1");
    }

    public function getPlayerProperty (key :String) :Object
    {
        return callHostCode("getPlayerProperty_v1", key);
    }

    public function setPlayerProperty (key :String, value :Object, persistent :Boolean) :Boolean
    {
        return callHostCode("setPlayerProperty_v1", key, value, persistent);
    }

    public function sendMessage (key :String, value :Object, playerId :int = 0) :Boolean
    {
        return callHostCode("sendMessage_v1", key, value, playerId);
    }

    /** @private */
    override protected function setUserProps (o :Object) :void
    {
        super.setUserProps(o);

        o["stateChanged_v1"] = stateChanged_v1;
        o["roomPropertyChanged_v1"] = roomPropertyChanged_v1;
        o["playerStateChanged_v1"] = playerStateChanged_v1;
        o["messageReceived_v1"] = messageReceived_v1;
    }

    /**
     * Called when a game-global state property has changed.
     * @private
     */
    protected function stateChanged_v1 (key :String, value :Object) :void
    {
        dispatch(new AVRGameControlEvent(AVRGameControlEvent.PROPERTY_CHANGED, key, value));
    }

    /**
     * Called when a local room property changed.
     * @private
     */
    protected function roomPropertyChanged_v1 (key :String, value :Object) :void
    {
        dispatch(new AVRGameControlEvent(AVRGameControlEvent.ROOM_PROPERTY_CHANGED, key, value));
    }

    /**
     * Called when a player-local state property has changed.
     * @private
     */
    protected function playerStateChanged_v1 (key :String, value :Object) :void
    {
        dispatch(new AVRGameControlEvent(AVRGameControlEvent.PLAYER_PROPERTY_CHANGED, key, value));
    }

    /**
     * Called when a user message has arrived.
     * @private
     */
    protected function messageReceived_v1 (key :String, value :Object) :void
    {
        dispatch(new AVRGameControlEvent(AVRGameControlEvent.MESSAGE_RECEIVED, key, value));
    }
}
}
