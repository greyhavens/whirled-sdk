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

/**
 * Dispatched when a message arrives with information that is not part of the shared game state.
 *
 * @eventType com.whirled.net.MessageReceivedEvent.MESSAGE_RECEIVED
 */
[Event(name="MsgReceived", type="com.whirled.net.MessageReceivedEvent")]

/**
 * Defines actions, accessors and callbacks available on the client only.
 */
public class RoomSubControl extends RoomBaseSubControl
{
    /** @private */
    public function RoomSubControl (ctrl :AbstractControl, targetId :int = 0)
    {
        super(ctrl, targetId);
    }

    public function get props () :PropertyGetSubControl
    {
        return _props;
    }

    /** @private */
    override protected function setUserProps (o :Object) :void
    {
        super.setUserProps(o);

        o["playerLeft_v1"] = playerLeft_v1;
        o["playerEntered_v1"] = playerEntered_v1;

        o["actorStateSet_v1"] = actorStateSet_v1;
        o["actorAppearanceChanged_v1"] = actorAppearanceChanged_v1;

        o["room_messageReceived_v1"] = messageReceived_v1;

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
        dispatch(new MessageReceivedEvent(_targetId, name, value, sender));
    }

    protected var _props :PropertyGetSubControlImpl;
}
}
