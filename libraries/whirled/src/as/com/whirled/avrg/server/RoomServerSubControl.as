//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg.server {

import com.whirled.AbstractControl;

import com.whirled.avrg.RoomSubControl;

import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.MessageSubControl;

/**
 * Dispatched when a message arrives for this room with information that is not part
 * of the shared game state.
 *
 * @eventType com.whirled.net.MessageReceivedEvent.MESSAGE_RECEIVED
 */
[Event(name="MsgReceived", type="com.whirled.net.MessageReceivedEvent")]

/** TODO: props needs to be PropertySubControl here, not PropertyGetSubControl */
public class RoomServerSubControl extends RoomSubControl
    implements MessageSubControl
{
    /** @private */
    public function RoomServerSubControl (ctrl :AbstractControl, targetId :int)
    {
        super(ctrl, targetId);

        if (targetId != getRoomId()) {
            throw new Error("Internal error [targetId=" + targetId + ", roomId=" +
                            getRoomId() + "]");
        }
    }

    public function spawnMob (id :String, name :String) :Boolean
    {
        return callHostCode("spawnMob_v1", id, name);
    }

    public function despawnMob (id :String) :Boolean
    {
        return callHostCode("despawnMob_v1", id);
    }

    /** Sends a message to all the players that are in the room. */
    public function sendMessage (name :String, value :Object) :void
    {
        callHostCode("room_srv_sendMessage_v1", name, value);
    }

    /** @private */
    override protected function setUserProps (o :Object) :void
    {
        super.setUserProps(o);

        o["room_srv_messageReceived_v1"] = messageReceived;
    }

    /**
     * Private method to post a MessageReceivedEvent.
     */
    private function messageReceived (name :String, value :Object, sender :int) :void
    {
        dispatch(new MessageReceivedEvent(_targetId, name, value, sender));
    }
}
}