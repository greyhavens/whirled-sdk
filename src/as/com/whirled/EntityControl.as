//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled {

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.utils.Timer;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.TimerEvent;

/**
 * Dispatched when the instance in control sends a trigger action to all instances.
 * 
 * @eventType com.whirled.ControlEvent.ACTION_TRIGGERED
 */
[Event(name="actionTriggered", type="com.whirled.ControlEvent")]

/**
 * Dispatched when any instance sends a message to all instances.
 * 
 * @eventType com.whirled.ControlEvent.MESSAGE_RECEIVED
 */
[Event(name="messageReceived", type="com.whirled.ControlEvent")]

/**
 * Dispatched when any instance sends a message to all instances of all entities.
 * 
 * @eventType com.whirled.ControlEvent.SIGNAL_RECEIVED
 */
[Event(name="signalReceived", type="com.whirled.ControlEvent")]

/**
 * Dispatched when the instance in control updates the memory of this digital item.
 *
 * @eventType com.whirled.ControlEvent.MEMORY_CHANGED
 */
[Event(name="memoryChanged", type="com.whirled.ControlEvent")]

/**
 * Dispatched when this instance gains control. See the <code>hasControl</code> method.
 *
 * @eventType com.whirled.ControlEvent.GOT_CONTROL
 */
[Event(name="gotControl", type="com.whirled.ControlEvent")]

/**
 * Dispatched once per tick, only when this instance has control and only if tick interval is
 * registered.
 * 
 * @eventType flash.events.TimerEvent.TIMER
 */
[Event(name="timer", type="flash.events.TimerEvent")]

/**
 * Handles services that are available to all entities in a room.  This includes dispatching
 * trigger events and maintaining memory.
 */
public class EntityControl extends WhirledControl
{
    /**
     */
    public function EntityControl (disp :DisplayObject)
    {
        super(disp);
    }

    /**
     * Returns our current logical location in the scene.  Note that if y is nonzero, you are
     * *flying*. If applicable, an avatar should animate appropriately. {@link
     * ActorControl#isMoving} may return true or false when flying, depending on whether you're
     * floating or actually moving between locations.
     *
     * @return an array containing [ x, y, z ]. x, y, and z are Numbers between 0 and 1 or null if
     * our location is unknown.
     */
    public function getLogicalLocation () :Array
    {
        return _location;
    }

    /**
     * Returns our current location in the scene, in pixel coordinates.
     */
    public function getPixelLocation () :Array
    {
        if (_location == null) {
            return null;
        }
        var bounds :Array = getRoomBounds();
        for (var ii :int = 0; ii < _location.length; ii++) {
            bounds[ii] *= _location[ii];
        }
        return bounds;
    }

    /**
     * Get the room's bounds in pixels.
     *
     * @return an array containing [ width, height, depth ].
     */
    public function getRoomBounds () :Array
    {
        return callHostCode("getRoomBounds_v1") as Array;
    }

    /**
     * Returns true if the local client has editing privileges in the current room.  Note that this
     * may change without notice. This value should be re-checked prior to persisting any sort of
     * setting in the entity memory.
     */
    public function canEditRoom () :Boolean
    {
        return callHostCode("canEditRoom_v1") as Boolean;
    }

    /**
     * Triggers an action on this scene object. The action will be properly distributed to the
     * object running in every client in the scene, resulting in a ACTION_TRIGGERED event.
     *
     * Note: the name must be a String and may be up to 64 characters.
     * TODO: restriction on size of the argument. It will probably be 1k or something.
     *
     * Note: Only the instance "in control" can trigger actions. If you want any instance to be
     * able to communicate, use sendMessage().
     */
    public function triggerAction (name :String, arg :Object = null) :void
    {
        callHostCode("sendMessage_v1", name, arg, true);
    }

    /**
     * Send a message to other instances of this entity, resulting in a MESSAGE_RECEIVED event.
     *
     * Note: the name must be a String and may be up to 64 characters.
     * TODO: restriction on size of the argument. It will probably be 1k or something.
     *
     * Note: Any instance can send messages. Compare with triggerAction.
     */
    public function sendMessage (name :String, arg :Object = null) :void
    {
        callHostCode("sendMessage_v1", name, arg, false);
    }

    /**
     * Send a message to all instances of all entities in this instance's current room,
     * resulting in a SIGNAL_RECEIVED event. All instances of the entity can initiate a
     * signal, so the user must take care to check for control when appropriate.
     *
     * Note: the name must be a String and may be up to 64 characters.
     * TODO: restriction on size of the argument. It will probably be 1k or something.
     */
    public function sendSignal (name :String, arg :Object = null) :void
    {
        callHostCode("sendSignal_v1", name, arg);
    }

    /**
     * Return an associative hash of all the memories. This is not a cheap operation. Use
     * lookupMemory if you know what you want. NOTE: Avatar memories are inconsistent at
     * the moment and should not be used.
     */
    public function getMemories () :Object
    {
        var mems :Object = callHostCode("getMemories_v1");
        // return an empty object if the host somereason returns null
        return (mems == null) ? {} : mems;
    }

    /**
     * Returns the value associated with the supplied key in this item's memory. If no value is
     * mapped in the item's memory, the supplied default value will be returned. NOTE:
     * Avatar memories are inconsistent at the moment and should not be used.
     *
     * @return the value for the specified key from this item's memory or the supplied default.
     */
    public function lookupMemory (key :String, defval :Object = null) :Object
    {
        var value :Object = callHostCode("lookupMemory_v1", key);
        return (value == null) ? defval : value;
    }

    /**
     * Is this client in control?
     *
     * <p>Control is a mutually exclusive lock across all instances of the entity (i.e. running in
     * other browsers across the network). Only one client can hold the lock at any time.
     *
     * <p>Note: control is <em>not</em> automatically assigned. If an entity wishes to obtain
     * control, it should first call <code>requestControl</code> and it will then receive a
     * <code>GOT_CONTROL</code> event if and when control has been assigned to this client.
     * There are no guarantees which of the requesting clients will receive it, or when. 
     */
    public function hasControl () :Boolean
    {
        return _hasControl;
    }

    /**
     * Request to have this client control all the instances of this entity. The other instances
     * are the same code, but running in other browsers. See the <code>hasControl</code> method.
     */
    public function requestControl () :void
    {
        callHostCode("requestControl_v1");
    }

    /**
     * Configures the interval on which this item is "ticked" in milliseconds. If the client
     * setting this interval is in control, it will get a <code>timer</code> event at the
     * specified interval. Otherwise, the entity will request control from the server, and only
     * set the timer once control was granted (if ever).
     *
     * <p>Ticking mechanism is turned off by default. Application needs to set the interval
     * explicitly to start receiving tick events. The tick interval can be no smaller than 100ms
     * to avoid bogging down the client.
     * 
     * @param interval Delay between ticks in milliseconds, either 0ms, or a value larger
     * than 100ms. Value larger than zero activates the ticking mechanism,
     * and a value of exactly zero deactivates it.
     */
    public function setTickInterval (interval :Number) :void
    {
        _tickInterval = (interval > 100 || interval <= 0) ? interval : 100;

        if (_hasControl) {
            recheckTicker();

        } else if (_tickInterval > 0) {
            requestControl();
        }
    }

    /**
     * Get the instance id of this instance.
     */
    public function getInstanceId () :int
    {
        return int(callHostCode("getInstanceId_v1"));
    }

    /**
     * Requests that this item's memory be updated with the supplied key/value pair. The supplied
     * value must be a simple object (Integer, Number, String) or an Array of simple objects. The
     * contents of the Pet's memory (keys and values) must not exceed 4096 bytes when AMF3 encoded.
     *
     * Setting the memory for a key to null clears that key; subsequent lookups will return the
     * default value.
     *
     * NOTE: Avatar memories are inconsistent at the moment and should not be used.
     *
     * @return true if the memory was updated, false if the memory update could not be completed
     * due to size restrictions.
     *
     * Note: any instance can update memories!
     */
    public function updateMemory (key :String, value :Object) :Boolean
    {
        return callHostCode("updateMemory_v1", key, value);
    }

    /**
     * Set the layout "hotspot" for your item, specified as pixels relative to (0, 0) the top-left
     * coordinate.
     *
     * If unset, the default hotspot will be based off of the SWF dimensions, with x = width / 2,
     * y = height.
     */
    public function setHotSpot (x :Number, y :Number, height :Number = NaN) :void
    {
        callHostCode("setHotSpot_v1", x, y, height);
    }

    /**
     * Show a popup to the current user in the whirled. This may ONLY be called inside of a
     * MOUSE_CLICK handler, to prevent malicious furniture from jamming up popups left and right.
     *
     * @param title The title displayed in the title bar for the popup.
     * @param panel The display object to show in the popup. It should only paint inside the
     *              rectangle defined by (0, 0, width, height).
     * @param width The width of the panel.
     * @param height The height of the panel.
     * @param backgroundColor The RGB value to fill the background of the panel with.
     * @param backgroundAlpha The transparency to fill the background of the panel with.
     *
     * @return true if the popup was shown, false if it could not be shown for various reasons.
     */
    public function showPopup (
        title :String, panel :DisplayObject, width :Number, height :Number,
        backgroundColor :uint = 0xFFFFFF, backgroundAlpha :Number = 1.0) :Boolean
    {
        return callHostCode("showPopup_v1", title, panel, width, height, backgroundColor, 
                            backgroundAlpha) as Boolean;
    }

    /**
     * Clear any showing popup. May be called at any time.
     */
    public function clearPopup () :void
    {
        callHostCode("clearPopup_v1");
    }

    /**
     * Populate any properties that we provide back to whirled.
     */
    override protected function populateProperties (o :Object) :void
    {
        o["memoryChanged_v1"] = memoryChanged_v1;
        o["gotControl_v1"] = gotControl_v1;
        o["messageReceived_v1"] = messageReceived_v1;
        o["signalReceived_v1"] = signalReceived_v1;
    }

    // from WhirledControl
    override protected function gotInitProperties (o :Object) :void
    {
        super.gotInitProperties(o);

        _location = (o["location"] as Array);
    }

    /**
     * Called when an action or message is triggered on this scene object.
     */
    protected function messageReceived_v1 (name :String, arg :Object, isAction :Boolean) :void
    {
        dispatch(isAction ? ControlEvent.ACTION_TRIGGERED
                          : ControlEvent.MESSAGE_RECEIVED, name, arg);
    }

    /**
     * Called when an action or message is triggered on this scene object.
     */
    protected function signalReceived_v1 (name :String, arg :Object) :void
    {
        dispatch(ControlEvent.SIGNAL_RECEIVED, name, arg);
    }

    /**
     * Called when one of this item's memory entries has changed.
     */
    protected function memoryChanged_v1 (key :String, value :Object) :void
    {
        dispatch(ControlEvent.MEMORY_CHANGED, key, value);
    }

    /**
     * Called when this client has been assigned control of this object.
     */
    protected function gotControl_v1 () :void
    {
        if (_hasControl) {
            return; // avoid re-dispatching
        }
        _hasControl = true;

        // dispatch to user code..
        dispatch(ControlEvent.GOT_CONTROL);

        // possibly set up a ticker now
        recheckTicker();
    }

    /**
     * Check the status of the ticker, starting or stopping it as necessary.
     */
    protected function recheckTicker () :void
    {
        if (_hasControl && _tickInterval > 0) {
            if (_ticker == null) {
                // we may be creating the timer for the first time
                _ticker = new Timer(_tickInterval);
                // re-route it
                _ticker.addEventListener(TimerEvent.TIMER, dispatchEvent);

            } else {
                // we may just be committing a new interval
                _ticker.delay = _tickInterval;
            }
            _ticker.start(); // start if not already running

        } else {
            stopTicker();
        }
    }

    /**
     * Stops our AI ticker.
     */
    protected function stopTicker () :void
    {
        if (_ticker != null) {
            _ticker.stop();
            _ticker = null;
        }
    }

    override protected function handleUnload (evt :Event) :void
    {
        super.handleUnload(evt);

        _hasControl = false;
        stopTicker();
    }

    /** Contains our current location in the scene [x, y, z], or null. */
    protected var _location :Array;

    /** Our desired tick interval (in milliseconds). */
    protected var _tickInterval :Number = 0;

    /** Used to tick this object when this client is running its AI. */
    protected var _ticker :Timer;

    /** Whether this instance has control. */
    protected var _hasControl :Boolean = false;
}
}
