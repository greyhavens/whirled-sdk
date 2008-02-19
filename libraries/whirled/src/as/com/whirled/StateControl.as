//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled {

/**
 * Dispatched when a game-global state property has changed.
 * 
 * @eventType com.whirled.AVRGameControlEvent.PROPERTY_CHANGED
 */
[Event(name="propertyChanged", type="com.whirled.AVRGameControlEvent")]

/**
 * Dispatched when a player-local state property has changed.
 * 
 * @eventType com.whirled.AVRGameControlEvent.PLAYER_PROPERTY_CHANGED
 */
[Event(name="playerPropertyChanged", type="com.whirled.AVRGameControlEvent")]

/**
 * Dispatched when a message has been received.
 * 
 * @eventType com.whirled.AVRGameControlEvent.MESSAGE_RECEIVED
 */
[Event(name="messageReceived", type="com.whirled.AVRGameControlEvent")]

public class StateControl extends AbstractSubControl
{
    public function StateControl (ctrl :AbstractControl)
    {
        super(ctrl)
    }

    public function getProperty (key :String) :Object
    {
        return callHostCode("getProperty_v1", key);
    }

    public function setProperty (key :String, value :Object, persistent :Boolean) :Boolean
    {
        return callHostCode("setProperty_v1", key, value, persistent);
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
        o["playerStateChanged_v1"] = playerStateChanged_v1;
        o["messageReceived_v1"] = messageReceived_v1;
    }

    /**
     * Called when a game-global state property has changed.
     */
    protected function stateChanged_v1 (key :String, value :Object) :void
    {
        dispatch(new AVRGameControlEvent(AVRGameControlEvent.PROPERTY_CHANGED, key, value));
    }

    /**
     * Called when a player-local state property has changed.
     */
    protected function playerStateChanged_v1 (key :String, value :Object) :void
    {
        dispatch(new AVRGameControlEvent(AVRGameControlEvent.PLAYER_PROPERTY_CHANGED, key, value));
    }

    /**
     * Called when a user message has arrived.
     */
    protected function messageReceived_v1 (key :String, value :Object) :void
    {
        dispatch(new AVRGameControlEvent(AVRGameControlEvent.MESSAGE_RECEIVED, key, value));
    }
}
}
