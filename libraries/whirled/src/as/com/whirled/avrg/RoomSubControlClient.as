//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg {

import com.whirled.AbstractControl;
import com.whirled.AbstractSubControl;

import com.whirled.TargetedSubControl;
import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.PropertyGetSubControl;
import com.whirled.net.impl.PropertyGetSubControlImpl;

import flash.utils.Dictionary;

/**
 * Dispatched when a message arrives with information that is not part of the shared game state.
 *
 * @eventType com.whirled.net.MessageReceivedEvent.MESSAGE_RECEIVED
 * @see RoomSubControlServer#sendMessage()
 */
[Event(name="MsgReceived", type="com.whirled.net.MessageReceivedEvent")]

/**
 * Provides AVR services for a client player's current room.
 * @see AVRGameControl#room
 */
public class RoomSubControlClient extends RoomSubControlBase
{
    /** @private */
    public function RoomSubControlClient (ctrl :AbstractControl, targetId :int = 0)
    {
        super(ctrl, targetId);
    }

    /**
     * Accesses the read-only properties associated with this room. To change properties use your
     * server agent's <code>RoomSubControlServer</code>'s <code>props</code>.
     * @see RoomSubControlServer#props
     */
    public function get props () :PropertyGetSubControl
    {
        return _props;
    }

    /** @inheritDoc */
    // from RoomSubControlBase
    override public function getRoomId () :int
    {
        return callHostCode("room_getRoomId_v1");
    }

    /**
     * Get the name of this room.
     */
    public function getRoomName () :String
    {
        return callHostCode("room_getRoomName_v1") as String;
    }

    /**
     * Enumerates the ids of all entities in this room.
     *
     * @param type an optional filter to restrict the results to a particular type of entity,
     * currently one of 'furni', 'avatar' or 'pet'.
     */
    public function getEntityIds (type :String = null) :Array
    {
        var entities :Array = callHostCode("getEntityIds_v1", type);
        return (entities == null) ? [] : entities;
    }

    /**
     * Looks up and returns the specified property for the specified entity.
     * Returns null if the entity does not exist or the entity has no such property.
     */
    public function getEntityProperty (key :String, entityId :String = null) :Object
    {
        return callHostCode("getEntityProperty_v1", entityId, key);
    }

    /**
     * Can the specified memberId manage the current room?
     */
    public function canManageRoom (memberId :int = 0) :Boolean
    {
        return callHostCode("room_canEditRoom_v1", memberId) as Boolean;
    }

    /**
     * Accesses a previosly spawned MOB in this room.
     * @see http://wiki.whirled.com/Mobs
     * @see RoomSubControlBase#event:mobControlAvailable
     */
    public function getMobSubControl (id :String) :MobSubControlClient
    {
        return _mobControls[id] as MobSubControlClient;
    }

    /** @private */
    override protected function setUserProps (o :Object) :void
    {
        super.setUserProps(o);

        o["playerLeft_v1"] = playerLeft_v1;
        o["playerEntered_v1"] = playerEntered_v1;
        o["actorStateSet_v1"] = actorStateSet_v1;
        o["actorAppearanceChanged_v1"] = actorAppearanceChanged_v1;
        o["playerMoved_v1"] = playerMoved_v1;
        o["room_messageReceived_v1"] = messageReceived_v1;
        o["signalReceived_v1"] = signalReceived_v1;
        o["mobRemoved_v1"] = mobRemoved_v1;
        o["mobAppearanceChanged_v1"] = mobAppearanceChanged_v1;
        // the client backend does not send in targetId
        o["room_propertyWasSet_v1"] = _props.propertyWasSet_v1;
    }

    /** @private */
    override protected function createSubControls () :Array
    {
        _props = new PropertyGetSubControlImpl(_parent, _targetId, "room_getGameData_v1");
        return [ _props ];
    }

    /** @private */
    internal function messageReceived_v1 (name :String, value :Object, sender :int) :void
    {
        dispatch(new MessageReceivedEvent(name, value, sender));
    }

    /** @private */
    internal function leftRoom () :void
    {
        // called on the client when we leave a room; reset any awareness of MOBs
        _mobControls = new Dictionary();
    }

    /** @private */
    protected var _props :PropertyGetSubControlImpl;
}
}
