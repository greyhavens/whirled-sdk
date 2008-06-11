//
// $Id$

package com.whirled.game {

import com.whirled.AbstractSubControl;

/**
 * Dispatched when a property has changed in the shared game state. This event is a result
 * of calling set() or testAndSet().
 *
 * @eventType com.whirled.game.PropertyChangedEvent.PROPERTY_CHANGED
 */
[Event(name="PropChanged", type="com.whirled.game.PropertyChangedEvent")]

/**
 * Dispatched when an element inside a property has changed in the shared game state.
 * This event is a result of calling setIn() or setAt().
 *
 * @eventType com.whirled.game.ElementChangedEvent.ELEMENT_CHANGED
 */
[Event(name="ElemChanged", type="com.whirled.game.ElementChangedEvent")]

/**
 * Dispatched when a message arrives with information that is not part of the shared game state.
 *
 * @eventType com.whirled.game.MessageReceivedEvent.MESSAGE_RECEIVED
 */
[Event(name="MsgReceived", type="com.whirled.game.MessageReceivedEvent")]

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
{
    /**
     * Constant provided to {@link #sendMessage} that will send a message to all subscribers.
     */
    public static const TO_ALL :int = 0;

    /**
     * Constant provided to {@link #sendMessage} that will send a message to the game's server
     * agent, if there is one.
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
     * Get a property value. Calling this method results in no network traffic, it just
     * examines values that have already arrived over the network to this client.
     *
     * @param propName the name of the property to retrieve.
     * @return the property value, or null if there is no property with that name.
     */
    public function get (propName :String) :Object
    {
        checkIsConnected();
        return _gameData[propName];
    }

    /**
     * Set a property value to be distributed to the other clients in this game.
     * Property values can be any of the primitive types: int, Number, Boolean, String,
     * ByteArray; or you may set Arrays, Dictionarys, or plain old Objects, as long as
     * the values within them are primitive types or other Arrays, Dictionarys and Objects.
     *
     * <p>You may not set your own classes as properties. However, you can serialize your data
     * into a ByteArray and set that.</p>
     * 
     * <p><b>Note</b>: top-level Dictionarys must have int keys, the intention is to use
     * occupantIds as keys.</p>
     *
     * <p>Note that if you set the value as an Array or Dictionary, the value is serialized
     * slightly differently in order to enable updating individual elements efficiently.
     * The individual elements will be serialized separately. You may update the elements
     * individually by using either setAt (for Arrays) or setIn (for Dictionarys). The
     * effect of serializing elements individually is that references to the same object will
     * not be reconstructed off the network as references to the same object. See the example
     * below.</p>
     *
     * @param propName the name of the property to set.
     * @param value the value to set. Passing null clears the property.
     * @param immediate if true, the value is updated immediately in the local object. Otherwise
     * any old value will remain in effect until the PropertyChangedEvent arrives after
     * a round-trip to the server.
     * 
     * @example
     * <listing version="3.0">
     * // demonstrates expert-level difference between setting values in an array and an object.
     * var o :Object = { blue: true };
     * var objTest :Object = { 0: o, 1: o};
     * var arrayTest :Array = [ o, o ];
     * _ctrl.net.set("object", objTest);
     * _ctrl.net.set("array", arrayTest);
     * 
     * // Later, when reading those values back out:
     * var obj :Object = _ctrl.net.get("object");
     * var array :Array = _ctrl.net.get("array") as Array;
     * trace("array: " + (array[0] == array[1])); // traces false
     * trace("object: " + (obj[0] == obj[1])); // traces true
     * </listing>
     *
     *
     * @see Array
     * @see flash.utils.Dictionary
     * @see #setAt()
     * @see #setIn()
     */
    public function set (propName :String, value :Object, immediate :Boolean = false) :void
    {
        callHostCode("setProperty_v2", propName, value, null, false, immediate);
    }

    /**
     * Update one element of an Array.<br/>
     * <b>Note</b>: Unlike setIn(), this update will fail silently if the index is out of
     * bounds or if there is no array currently set at the specified property name.
     * Furthermore, if you set the element with immediate=true, there are two updates:
     * one locally that happens right away and the update on the server that will be
     * dispatched back to all the clients. Either or both can fail, so be sure to set the Array up
     * first using set().
     *
     * @param propName the name of the property to modify.
     * @param index the array index of the element to update.
     * @param value the value to set.
     * @param immediate if true, the value is updated immediately in the local object. Otherwise
     * any old value will remain in effect until the ElementChangedEvent arrives after
     * a round-trip to the server.
     *
     * @see #set()
     */
    public function setAt (
        propName :String, index :int, value :Object, immediate :Boolean = false) :void
    {
        callHostCode("setProperty_v2", propName, value, index, true, immediate);
    }

    /**
     * Update one element of a Dictionary.<br/>
     * <b>Note</b>: Unlike setAt(), this will always work. No key is out of range, and if
     * this is called on a property that doesn't currently contain a Dictionary, one will
     * be automatically created and inserted at the specified property name.
     *
     * @param propName the name of the property to modify.
     * @param key the key of the element to update.
     * @param value the value to set. Passing null removes the specified key from the Dictionary.
     * @param immediate if true, the value is updated immediately in the local object. Otherwise
     * any old value will remain in effect until the ElementChangedEvent arrives after
     * a round-trip to the server.
     */
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

    /**
     * Get the names of all currently-set properties that begin with the specified prefix.
     * Calling this method results in no network traffic.
     */
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
     * @param playerId if {@link #TO_ALL} (or unset), sends to all players, 
     * otherwise the message will be private to just one player; if the game employs a server agent, 
     * {@link #TO_SERVER_AGENT} may be used to send a message only to the server.
     */
    public function sendMessage (messageName :String, value :Object, playerId :int = TO_ALL) :void
    {
        callHostCode("sendMessage_v2", messageName, value, playerId);
    }

    /**
     * Send a message privately to the game's server agent, if there is one. This is a shortcut 
     * for calling {@link #sendMessage} with playerId set to {@link #TO_SERVER_AGENT}.
     *
     * @param messageName The message to send.
     * @param value The value to attach to the message.
     */
    public function sendMessageToAgent (messageName :String, value :Object) :void
    {
        sendMessage(messageName, value, TO_SERVER_AGENT);
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

    /**
     * Private method to post a PropertyChangedEvent.
     */
    private function propertyWasSet_v2 (
        name :String, newValue :Object, oldValue :Object, key :Object) :void
    {
        if (key == null) {
            dispatch(new PropertyChangedEvent(PropertyChangedEvent.PROPERTY_CHANGED,
                name, newValue, oldValue));
        } else {
            dispatch(new ElementChangedEvent(ElementChangedEvent.ELEMENT_CHANGED,
                name, newValue, oldValue, int(key)));
        }
    }

    /**
     * Private method to post a MessageReceivedEvent.
     */
    private function messageReceived_v2 (name :String, value :Object, sender :int) :void
    {
        dispatch(new MessageReceivedEvent(name, value, sender));
    }

    /** Game properties. @private */
    protected var _gameData :Object;
}
}
