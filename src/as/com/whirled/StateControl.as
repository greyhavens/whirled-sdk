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

public class StateControl extends WhirledSubControl
{
    public function StateControl (ctrl :WhirledControl)
    {
        super(ctrl)
    }

    public function getProperty (key :String) :Object
    {
        return _ctrl.callHostCodeFriend("getProperty_v1", key);
    }

    public function setProperty (key :String, value :Object, persistent :Boolean) :Boolean
    {
        return _ctrl.callHostCodeFriend("setProperty_v1", key, value, persistent);
    }

    public function getPlayerProperty (key :String) :Object
    {
        return _ctrl.callHostCodeFriend("getPlayerProperty_v1", key);
    }

    public function setPlayerProperty (key :String, value :Object, persistent :Boolean) :Boolean
    {
        return _ctrl.callHostCodeFriend("setPlayerProperty_v1", key, value, persistent);
    }

    public function sendMessage (key :String, value :Object, playerId :int = 0) :Boolean
    {
        return _ctrl.callHostCodeFriend("sendMessage_v1", key, value, playerId);
    }

    internal function populateSubProperties (o :Object) :void
    {
        o["stateChanged_v1"] = stateChanged_v1;
        o["playerStateChanged_v1"] = playerStateChanged_v1;
        o["messageReceived_v1"] = messageReceived_v1;
    }

    /**
     * Called when a game-global state property has changed.
     */
    protected function stateChanged_v1 (key :String, value :Object) :void
    {
        dispatchEvent(new AVRGameControlEvent(
            AVRGameControlEvent.PROPERTY_CHANGED, key, value));
    }

    /**
     * Called when a player-local state property has changed.
     */
    protected function playerStateChanged_v1 (key :String, value :Object) :void
    {
        dispatchEvent(new AVRGameControlEvent(
            AVRGameControlEvent.PLAYER_PROPERTY_CHANGED, key, value));
    }

    /**
     * Called when a user message has arrived.
     */
    protected function messageReceived_v1 (key :String, value :Object) :void
    {
        dispatchEvent(new AVRGameControlEvent(
            AVRGameControlEvent.MESSAGE_RECEIVED, key, value));
    }
}
}
