//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled {

import flash.display.DisplayObject;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.TimerEvent;

import flash.media.Camera;
import flash.media.Microphone;

import flash.utils.ByteArray;
import flash.utils.Timer;

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
 * Dispatched when the instance in control updates a room property.
 *
 * @eventType com.whirled.ControlEvent.ROOM_PROPERTY_CHANGED
 */
[Event(name="roomPropertyChanged", type="com.whirled.ControlEvent")]

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
 * Dispatched when an entity enters the room.
 *
 * @eventType com.whirled.ControlEvent.ENTITY_ENTERED
 */
[Event(name="entityEntered", type="com.whirled.ControlEvent")]

/**
 * Dispatched when an entity leaves the room.
 *
 * @eventType com.whirled.ControlEvent.ENTITY_LEFT
 */
[Event(name="entityLeft", type="com.whirled.ControlEvent")]

/**
 * Dispatched when an entity in the room (other than the listening entity) changes location.
 *
 * @eventType com.whirled.ControlEvent.ENTITY_MOVED
 */
[Event(name="entityMoved", type="com.whirled.ControlEvent")]

/**
 * Handles services that are available to all entities in a room.  This includes dispatching
 * trigger events and maintaining memory.
 */
public class EntityControl extends AbstractControl
{
    // special entity type used with getEntityIds()
    public static const ALL :String = null;

    // entity types
    public static const FURNI :String = "furni"; // encompasses furni, decor and toys
    public static const AVATAR :String = "avatar";
    public static const PET :String = "pet";

    // special entity id used with getEntityProperty()
    public static const ME :String = null;

    /**
     * The entity's location in logical coordinates (an Array [ x, y, z ]). x, y, and z are Numbers
     * between 0 and 1 or null if our location is unknown. Use with getEntityProperty().
     */
    public static const LOCATION_LOGICAL :String = "std:location_logical";

    /**
     * The entity's location in pixel coordinates (an Array [ x, y, z ]). Obviously there is not a
     * real Z coordinate, but the value will coorrespond to real Z distance in proportion to the
     * distance in X and Y. Use with getEntityProperty().
     */
    public static const LOCATION_PIXEL :String = "std:location_pixel";

    /** The entity's hot spot (an Array [x, y]). Use with getEntityProperty(). */
    public static const HOTSPOT :String = "std:hotspot";

    /** The entity pixel dimensions (an Array [width, height]). Use with getEntityProperty(). */
    public static const DIMENSIONS :String = "std:dimensions";

    /** The entity facing direction (a Number). Use with getEntityProperty(). */
    public static const ORIENTATION :String = "std:orientation";

    /**
     * @private
     */
    public function EntityControl (disp :DisplayObject)
    {
        super(disp);

        if (Object(this).constructor == EntityControl) {
            throw new Error("Do not directly use EntityContrl. " +
                "Use the appropriate subclass: AvatarControl, FurniControl, etc.");
        }
    }

    /**
     * Get the default datapack for this entity, or null if there is none defined.
     * The DataPack is returned as a ByteArray, which can easily be passed to the
     * com.whirled.DataPack constructor. We do not return a DataPack for you, because otherwise
     * including this class would include all the DataPack support classes, even if your
     * project never made use of it.
     */
    // TODO: better documentation, better name? (default is not the greatest)
    // TODO: Gawd, it'd be nice to be able to clear this once the user grabs it, so that
    // we don't have these bytes in memory as well as all the decoded info in the DataPack...
    public function getDefaultDataPack () :ByteArray
    {
        return _datapack;
    }

    /**
     * Returns our current logical location in the scene.  Note that if y is nonzero, you are
     * *flying*. If applicable, an avatar should animate appropriately. <code>isMoving()</code>
     * may return true or false when flying, depending on whether you're
     * floating or actually moving between locations.
     *
     * @return an array containing [ x, y, z ]. x, y, and z are Numbers between 0 and 1 or null if
     * our location is unknown.
     *
     * @see com.whirled.ActorControl#isMoving()
     */
    public function getLogicalLocation () :Array
    {
        return _location;
    }

    /**
     * Returns our current location in the scene, in pixel coordinates.
     *
     * @return an array containing [ x, y, z ] in pixel coordinates. Obviously there is not a
     * real Z coordinate, but the value will coorrespond to real Z distance in proportion
     * to the distance in X and Y.
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
     * Note: the name must be a String and may be up to 64 characters. The argument may be up
     * to 1024 bytes after being AMF3 encoded.
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
     * Note: the name must be a String and may be up to 64 characters. The argument may be up
     * to 1024 bytes after being AMF3 encoded.
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
     * Note: the name must be a String and may be up to 64 characters. The argument may be up
     * to 1024 bytes after being AMF3 encoded.
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
     * Return an associative hash of all the room properties. This is not a cheap operation.
     * Use getRoomProperty if you know what you want.
     *
     * <p><b>Note</b>: Room properties are an experimental feature and may be removed or
     * incompatibly changed in the future. Use at your own risk. If you want to create something
     * that depends on this, tell us about it and we'll try to account for that 
     * in any changes we make.</p>
     */
    public function getRoomProperties () :Object
    {
        var mems :Object = callHostCode("getRoomProperties_v1");
        // return an empty object if the host somereason returns null
        return (mems == null) ? {} : mems;
    }

    /**
     * Returns the value associated with the supplied key in thie room's shared property space.
     * If no value is mapped in the room, the supplied default value will be returned.
     *
     * @return the value for the specified key from this room's property space or the
     * supplied default.
     *
     * <p><b>Note</b>: Room properties are an experimental feature and may be removed or
     * incompatibly changed in the future. Use at your own risk. If you want to create something
     * that depends on this, tell us about it and we'll try to account for that 
     * in any changes we make.</p>
     */
    public function getRoomProperty (key :String, defval :Object = null) :Object
    {
        var value :Object = callHostCode("getRoomProperty_v1", key);
        return (value == null) ? defval : value;
    }

    /**
     * Requests that the room's shared property space be updated with the supplied key/value
     * pair. The supplied value must be a simple object (Integer, Number, String) or an Array
     * of simple objects. The key must be no more than 64 bytes long and the value no more
     * than 256 when encoded. There can be no more than 16 entries in a room's property space
     * so be frugal.
     *
     * Please note that these properties are not persisted through server reboots. They are
     * meant for state coordination, not long-term storage. Use item memory for persistence.
     *
     * Setting the value for a key to null clears that property; subsequent lookups will return
     * the default value.
     *
     * @return true if the memory was updated, false if the memory update could not be completed
     * due to size restrictions.
     *
     * <p><b>Note</b>: Room properties are an experimental feature and may be removed or
     * incompatibly changed in the future. Use at your own risk. If you want to create something
     * that depends on this, tell us about it and we'll try to account for that 
     * in any changes we make.</p>
     */
    public function setRoomProperty (key :String, value :Object) :Boolean
    {
        return callHostCode("setRoomProperty_v1", key, value);
    }

    /**
     * Enumerates the ids of all entities in this room.
     *
     * @param type an optional filter to restrict the results to a particular type of entity.
     */
    public function getEntityIds (type :String = ALL) :Array
    {
        var entities :Array = callHostCode("getEntityIds_v1", type);
        return (entities == null) ? [] : entities;
    }

    /**
     * Returns the type of the entity with the supplied id.
     */
    public function getEntityType (entityId :String = ME) :String
    {
        return callHostCode("getEntityType_v1", entityId);
    }

    /**
     * Looks up and returns the specified property for the specified entity. Returns null if the entity
     * does not exist or the entity has no such property.
     */
    public function getEntityProperty (key :String, entityId :String = ME) :Object
    {
        return callHostCode("getEntityProperty_v1", entityId, key);
    }

    /**
     * Registers a function that provides custom entity properties. This should be done immediately
     * after creating your EntityControl, for example:
     *
     * var ctrl :FurniControl = new FurniControl(this);
     * ctrl.registerPropertyProvider(getEntityProperty);
     *
     * @param func signature: function (key :String) :Object
     */
    public function registerPropertyProvider (func :Function) :void
    {
        _propertyProvider = func;
    }

    /**
     * Deletes this entity from the player's inventory and removed it from the room.
     */
    public function selfDestruct () :void
    {
        callHostCode("selfDestruct_v1");
    }

    /**
     * Is this client in control?
     *
     * <p>Control is a mutually exclusive lock across all instances of the entity (i.e. running in
     * other browsers across the network). Only one client can hold the lock at any time.</p>
     *
     * <p>Note: control is <em>not</em> automatically assigned. If an entity wishes to obtain
     * control, it should first call <code>requestControl</code> and it will then receive a
     * <code>GOT_CONTROL</code> event if and when control has been assigned to this client.
     * There are no guarantees which of the requesting clients will receive it, or when.</p>
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
     * to avoid bogging down the client.</p>
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
     * Get the id of the viewer that is viewing this instance.
     * An instance is the copy of the entity running in a particular user's browser.
     * If you are in a room with 2 other people, each piece of furniture has three instances:
     * one on each person's browser.
     *
     * @return the memberId of the player viewing this instance. Only ids greater than 0
     * represent whirled members. Ids less than 0 represent guests, and 0 means that the
     * instance is being viewed by something other than a player.
     */
    public function getInstanceId () :int
    {
        return int(callHostCode("getInstanceId_v1"));
    }

    /**
     * Get the non-unique display name of the user viewing a particular instance. Note
     * that this cannot be used to look up member names of people who are not in the room.
     *
     * @param id a permanent memberId or transient guestId, or 0 to just get this instance's
     * viewer name without first calling getInstanceId() to get the id.
     *
     * @return a String or null if the viewer is unknown.
     */
    public function getViewerName (id :int = 0) :String
    {
        return callHostCode("getViewerName_v1", id) as String;
    }

    /**
     * Set the layout "hotspot" for your item, specified as pixels relative to (0, 0) the top-left
     * coordinate.
     *
     * If unset, the default hotspot will be based off of the SWF dimensions, with x = width / 2,
     * y = height.
     *
     * @param x the new hotspot x coordinate
     * @param y the new hotspot y coordinate
     * @param height if specified, the entity's actual current height, as pixels above the hotspot.
     *               This is used by avatars to position the name label.
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
     * Access the local user's camera.
     * Calling Camera.getCamera() does not work inside whirled due to security restrictions.
     * For convenience, this method works even when you're not connected.
     */
    public function getCamera (index :String = null) :Camera
    {
        return isConnected() ? callHostCode("getCamera_v1", index) as Camera
                             : Camera.getCamera(index);
    }

    /**
     * Access the local user's camera.
     * Calling Microphone.getMicrophone() does not work inside whirled due to security restrictions.
     * For convenience, this method works even when you're not connected.
     */
    public function getMicrophone (index :int = 0) :Microphone
    {
        return isConnected() ? callHostCode("getMicrophone_v1", index) as Microphone
                             : Microphone.getMicrophone(index)
    }

    /**
     * Populate any properties that we provide back to whirled.
     * @private
     */
    override protected function setUserProps (o :Object) :void
    {
        super.setUserProps(o);

        o["memoryChanged_v1"] = memoryChanged_v1;
        o["roomPropertyChanged_v1"] = roomPropertyChanged_v1;
        o["gotControl_v1"] = gotControl_v1;
        o["messageReceived_v1"] = messageReceived_v1;
        o["signalReceived_v1"] = signalReceived_v1;

        o["entityEntered_v1"] = entityEntered_v1;
        o["entityLeft_v1"] = entityLeft_v1;
        o["entityMoved_v1"] = entityMoved_v1;
        o["lookupEntityProperty_v1"] = lookupEntityProperty_v1;
    }

    /** @private */
    override protected function gotHostProps (o :Object) :void
    {
        super.gotHostProps(o);

        if ("initProps" in o) {
            gotInitProps(o.initProps);
            delete o.initProps; // not needed after startup
        }
    }

    /** @private */
    override protected function checkIsConnected () :void
    {
        // Nothing. It's ok for entity code to attempt to call methods even when not connected.
    }

    /**
     * Entities get another packet of data called the initProps.
     *
     * @private
     */
    protected function gotInitProps (o :Object) :void
    {
        _location = (o["location"] as Array);
        _datapack = (o["datapack"] as ByteArray);
    }

    /**
     * Helper method to dispatch a ControlEvent, avoiding creation if there are no listeners.
     */
    internal function dispatchCtrlEvent (
        ctrlEvent :String, key :String = null, value :Object = null) :void
    {
        if (hasEventListener(ctrlEvent)) {
            dispatch(new ControlEvent(ctrlEvent, key, value));
        }
    }

    /**
     * Called when an action or message is triggered on this scene object.
     * @private
     */
    protected function messageReceived_v1 (name :String, arg :Object, isAction :Boolean) :void
    {
        dispatchCtrlEvent(isAction ? ControlEvent.ACTION_TRIGGERED
                                   : ControlEvent.MESSAGE_RECEIVED, name, arg);
    }

    /**
     * Called when an action or message is triggered on this scene object.
     * @private
     */
    protected function signalReceived_v1 (name :String, arg :Object) :void
    {
        dispatchCtrlEvent(ControlEvent.SIGNAL_RECEIVED, name, arg);
    }

    /**
     * Called when one of this item's memory entries has changed.
     * @private
     */
    protected function memoryChanged_v1 (key :String, value :Object) :void
    {
        dispatchCtrlEvent(ControlEvent.MEMORY_CHANGED, key, value);
    }

    /**
     * Called when one of this item's memory entries has changed.
     * @private
     */
    protected function roomPropertyChanged_v1 (key :String, value :Object) :void
    {
        dispatchCtrlEvent(ControlEvent.ROOM_PROPERTY_CHANGED, key, value);
    }

    protected function entityEntered_v1 (entityId :String) :void
    {
        dispatchCtrlEvent(ControlEvent.ENTITY_ENTERED, entityId);
    }

    protected function entityLeft_v1 (entityId :String) :void
    {
        dispatchCtrlEvent(ControlEvent.ENTITY_LEFT, entityId);
    }

    protected function entityMoved_v1 (entityId :String) :void
    {
        dispatchCtrlEvent(ControlEvent.ENTITY_MOVED, entityId);
    }

    /**
     * Called when some other entity is requesting a property from this sprite.
     */
    protected function lookupEntityProperty_v1 (key :String) :Object
    {
        return (_propertyProvider == null ? null : _propertyProvider(key));
    }

    /**
     * Called when this client has been assigned control of this object.
     * @private
     */
    protected function gotControl_v1 () :void
    {
        if (_hasControl) {
            return; // avoid re-dispatching
        }
        _hasControl = true;

        // dispatch to user code..
        dispatchCtrlEvent(ControlEvent.GOT_CONTROL);

        // possibly set up a ticker now
        recheckTicker();
    }

    /**
     * Check the status of the ticker, starting or stopping it as necessary.
     * @private
     */
    protected function recheckTicker () :void
    {
        if (_hasControl && _tickInterval > 0) {
            if (_ticker == null) {
                // we may be creating the timer for the first time
                _ticker = new Timer(_tickInterval);
                // re-route it
                _ticker.addEventListener(TimerEvent.TIMER, dispatch);

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
     * @private
     */
    protected function stopTicker () :void
    {
        if (_ticker != null) {
            _ticker.stop();
            _ticker = null;
        }
    }

    /**
     * @private
     */
    override protected function handleUnload (evt :Event) :void
    {
        super.handleUnload(evt);

        _hasControl = false;
        stopTicker();
    }

    /** Contains our current location in the scene [x, y, z], or null. @private */
    protected var _location :Array;

    /** Our desired tick interval (in milliseconds). @private */
    protected var _tickInterval :Number = 0;

    /** Used to tick this object when this client is running its AI. @private */
    protected var _ticker :Timer;

    /** Whether this instance has control. @private */
    protected var _hasControl :Boolean = false;

    /** The default datapack, if any. @private */
    protected var _datapack :ByteArray;

    /** User specified callback to publish properties. */
    protected var _propertyProvider :Function;
}
}
