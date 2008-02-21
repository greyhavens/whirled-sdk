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
 * The 'net' subcontrol is used to communicate shared state between game clients.
 */
public class NetSubControl extends AbstractSubControl
{
    /**
     * @private Constructed via GameControl.
     */
    public function NetSubControl (parent :GameControl)
    {
        super(parent);
    }

    /**
     * Get a property value.
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
     * Set a property value. Note that if you set the value as an Array or Dictionary,
     * you can update the values within by using either setAt (for Arrays) or
     * setIn (for Dictionarys) to efficiently update and distribute just that one change.
     * Note that Dictionarys must have int keys, the intention is to use occupantIds as keys.
     *
     * @param propName the name of the property to set.
     * @param value the value to set. Passing null clears the property.
     * @param immediate if true, the value is updated immediately in the local object. Otherwise
     * any old value will remain in effect until the PropertyChangedEvent arrives after
     * a round-trip to the server.
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
     * @param playerId if 0 (or unset), sends to all players, otherwise the message will be private
     * to just one player
     */
    public function sendMessage (messageName :String, value :Object, playerId :int = 0) :void
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
        o["messageReceived_v1"] = messageReceived_v1;
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
    private function messageReceived_v1 (name :String, value :Object) :void
    {
        dispatch(new MessageReceivedEvent(name, value));
    }

    /** Game properties. @private */
    protected var _gameData :Object;
}
}
