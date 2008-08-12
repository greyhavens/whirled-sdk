//
// $Id$

package com.whirled.game {

import com.whirled.AbstractSubControl;

import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.MessageSubControl;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.PropertyChangedEvent;
import com.whirled.net.PropertySubControl;
import com.whirled.net.impl.MessageSubControlAdapter;
import com.whirled.net.impl.PropertySubControlImpl;

import flash.utils.Dictionary;

/**
 * Dispatched when a property has changed in the shared game state. This event is a result
 * of calling set() or testAndSet().
 *
 * @eventType com.whirled.net.PropertyChangedEvent.PROPERTY_CHANGED
 */
[Event(name="PropChanged", type="com.whirled.net.PropertyChangedEvent")]

/**
 * Dispatched when an element inside a property has changed in the shared game state.
 * This event is a result of calling setIn() or setAt().
 *
 * @eventType com.whirled.net.ElementChangedEvent.ELEMENT_CHANGED
 */
[Event(name="ElemChanged", type="com.whirled.net.ElementChangedEvent")]

/**
 * Dispatched when a message arrives with information that is not part of the shared game state.
 *
 * @eventType com.whirled.net.MessageReceivedEvent.MESSAGE_RECEIVED
 */
[Event(name="MsgReceived", type="com.whirled.net.MessageReceivedEvent")]

/**
 * Provides access to 'net' game services. Do not instantiate this class yourself,
 * access it via GameControl.net.
 *
 * The 'net' subcontrol is used to communicate shared state between game clients. When you set
 * a property it is immediately distributed to the other clients in the game. Reading a property
 * is immediate, you are reading the properties that have already been distributed. When a client
 * connects to an already-running game, any properties already set will be available.
 */
public class NetSubControl extends AbstractSubControl
    implements PropertySubControl
{
    /**
     * Constant provided to <code>sendMessage</code> that will send a message to all subscribers.
     * @see #sendMessage()
     */
    public static const TO_ALL :int = 0;

    /**
     * Constant provided to <code>sendMessage</code> that will send a message to the game's server
     * agent, if there is one.
     * @see #sendMessage()
     */
    public static const TO_SERVER_AGENT :int = int.MIN_VALUE;

    /**
     * @private Constructed via GameControl.
     */
    public function NetSubControl (parent :GameControl)
    {
        super(parent);
    }

    /**
     * Provides a control with which to send messages to all the players of this game.
     * @see #sendMessage
     */
    public function get players () :MessageSubControl
    {
        return _playersMsgCtrl;
    }

    /**
     * Provides a control with which to send messages to the server agent.
     * @see #sendMessage
     */
    public function get agent () :MessageSubControl
    {
        return _agentMsgCtrl;
    }

    /**
     * Provides a per-player way to send messages to a specific player.
     * @see #sendMessage
     */
    public function getPlayer (playerId :int) :MessageSubControl
    {
        return getPlayerMessager(playerId);
    }

    /** @inheritDoc */
    public function get (propName :String) :Object
    {
        checkIsConnected();
        return _gameData[propName];
    }

    /** @inheritDoc */
    public function set (propName :String, value :Object, immediate :Boolean = false) :void
    {
        callHostCode("setProperty_v2", propName, value, null, false, immediate);
    }

    /** @inheritDoc */
    public function setAt (
        propName :String, index :int, value :Object, immediate :Boolean = false) :void
    {
        callHostCode("setProperty_v2", propName, value, index, true, immediate);
    }

    /** @inheritDoc */
    public function setIn (
        propName :String, key :int, value :Object, immediate :Boolean = false) :void
    {
        callHostCode("setProperty_v2", propName, value, key, false, immediate);
    }

    /**
     * Set a property that will be distributed, but only if it's equal to the specified test value.
     *
     * <p> Please note that there is no way to test and set a property immediately,
     * because the value must be sent to the server to perform the test.</p>
     *
     * <p> The operation is 'atomic', in the sense that testing and setting take place during the
     * same server event. In comparison, a separate 'get' followed by a 'set' operation would
     * first read the current value as seen on your client and then send a request to overwrite
     * any value with a new value. By the time the 'set' reaches the server the old value
     * may no longer be valid. Since that's sketchy, we have this method.</p>
     */
    public function testAndSet (propName :String, newValue :Object, testValue :Object) :void
    {
        callHostCode("testAndSetProperty_v1", propName, newValue, testValue);
    }

    /** @inheritDoc */
    public function getPropertyNames (prefix :String = "") :Array
    {
        var props :Array = [];
        for (var s :String in _gameData) {
            if (s.lastIndexOf(prefix, 0) == 0) {
                props.push(s);
            }
        }
        return props;
    }

    /**
     * Send a "message" to other clients subscribed to the game.  These is similar to setting a
     * property, except that the value will not be saved- it will merely end up coming out as a
     * MessageReceivedEvent.
     *
     * @param messageName The message to send.
     * @param value The value to attach to the message.
     * @param playerId if <code>TO_ALL</code> (or unset), sends to all players, 
     * otherwise the message will be private to just one player; if the game employs a server agent, 
     * <code>TO_SERVER_AGENT</code> may be used to send a message only to the server.
     * @see #TO_ALL
     * @see #TO_SERVER_AGENT
     */
    public function sendMessage (messageName :String, value :Object, playerId :int = TO_ALL) :void
    {
        callHostCode("sendMessage_v2", messageName, value, playerId);
    }

    /**
     * @private
     */
    override protected function setUserProps (o :Object) :void
    {
        super.setUserProps(o);

        o["propertyWasSet_v2"] = propertyWasSet_v2;
        o["messageReceived_v2"] = messageReceived_v2;
    }

    /**
     * @private
     */
    override protected function gotHostProps (o :Object) :void
    {
        super.gotHostProps(o);

        _gameData = o.gameData;
    }

    /** @private */
    override protected function createSubControls () :Array
    {
        _agentMsgCtrl = new MessageSubControlAdapter(
            function (name :String, value :Object) :void {
                sendMessage(name, value, TO_SERVER_AGENT);
            });

        _playersMsgCtrl = new MessageSubControlAdapter(
            function (name :String, value :Object) :void {
                sendMessage(name, value, TO_ALL);
            });

        return [ _agentMsgCtrl, _playersMsgCtrl ];
    }



    /**
     * Look up or create a MessageSubControl for a specific player.
     * @private
     */
    protected function getPlayerMessager (playerId :int) :MessageSubControl
    {
        var ctrl :MessageSubControl = _playerCtrls[playerId];
        if (ctrl == null) {
            ctrl = _playerCtrls[playerId] = new MessageSubControlAdapter(
                function (name :String, value :Object) :void {
                    sendMessage(name, value, playerId);
                });
        }
        return ctrl;
    }

    /**
     * Private method to post a PropertyChangedEvent.
     */
    private function propertyWasSet_v2 (
        name :String, newValue :Object, oldValue :Object, key :Object) :void
    {
        var myId :int = int(callHostCode("getMyId_v1"));
        if (key == null) {
            dispatch(new PropertyChangedEvent(PropertyChangedEvent.PROPERTY_CHANGED,
                myId, name, newValue, oldValue));
        } else {
            dispatch(new ElementChangedEvent(ElementChangedEvent.ELEMENT_CHANGED,
                myId, name, newValue, oldValue, int(key)));
        }
    }

    /**
     * Private method to post a MessageReceivedEvent.
     */
    private function messageReceived_v2 (name :String, value :Object, sender :int) :void
    {
        var myId :int = int(callHostCode("getMyId_v1"));
        dispatch(new MessageReceivedEvent(myId, name, value, sender));
    }

    /** Game properties. @private */
    protected var _gameData :Object;

    /* @private */
    protected var _agentMsgCtrl :MessageSubControl;

    /* @private */
    protected var _playersMsgCtrl :MessageSubControl;

    /* @private */
    protected var _playerCtrls :Dictionary = new Dictionary();
}
}
