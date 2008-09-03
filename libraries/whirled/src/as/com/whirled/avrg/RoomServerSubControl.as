//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg {

import com.whirled.AbstractControl;

import com.whirled.avrg.RoomBaseSubControl;

import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.MessageSubControl;
import com.whirled.net.PropertySubControl;
import com.whirled.net.impl.PropertySubControlImpl;

public class RoomServerSubControl extends RoomBaseSubControl
    implements MessageSubControl
{
    /** @private */
    public function RoomServerSubControl (ctrl :AbstractControl, targetId :int)
    {
        super(ctrl, targetId);
    }

    public function get props () :PropertySubControl
    {
        return _props;
    }

    public function spawnMob (id :String, name :String) :void
    {
        callHostCode("spawnMob_v1", id, name);
    }

    public function despawnMob (id :String) :void
    {
        callHostCode("despawnMob_v1", id);
    }

    /** Sends a message to all the players that are in the room. */
    public function sendMessage (name :String, value :Object = null) :void
    {
        callHostCode("room_sendMessage_v1", name, value);
    }

    internal function gotHostPropsFriend (o :Object) :void
    {
        gotHostProps(o);
    }

    /** @private -- relayed from AVRServerGameControl when mob spawn is successful. */
    internal function mobSpawned_v1 (mobId :String) :void
    {
        // TODO: we should also report server-side MOB spawning errors to the game
        setMobSubControl(mobId, new MobServerSubControl(AVRServerGameControl(_parent), mobId));
    }

    /** @private */
    override protected function createSubControls () :Array
    {
        _props = new PropertySubControlImpl(
            _parent, _targetId, "room_getGameData_v1", "room_setProperty_v1");
        return [ _props ];
    }

    protected var _props :PropertySubControl;
}
}
