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

    public function getRoomId () :int
    {
        return _targetId;
    }

    public function spawnMob (id :String, name :String, x :Number, y :Number, z :Number) :void
    {
        callHostCode("spawnMob_v1", id, name, x, y, z);
    }

    public function despawnMob (id :String) :void
    {
        callHostCode("despawnMob_v1", id);
    }

    public function getMobSubControl (id :String) :MobServerSubControl
    {
        return _mobControls[id] as MobServerSubControl;
    }

    /** Sends a message to all the players that are in the room. */
    public function sendMessage (name :String, value :Object = null) :void
    {
        callHostCode("room_sendMessage_v1", name, value);
    }

    /** @private */
    internal function gotHostPropsFriend (o :Object) :void
    {
        gotHostProps(o);
    }

    /** @private */
    override protected function gotHostProps (o :Object) :void
    {
        super.gotHostProps(o);

        // Make sure we create all the mob controls that happen to be lying around in this room. 
        // Also delay the event dispatch because they are useless when called during construction
        // of the dispatcher!
        var delayEvent :Boolean = true;
        var mobIds :Array = callHostCode("getSpawnedMobs_v1") as Array;
        for each (var mobId :String in mobIds) {
            setMobSubControl(mobId, new MobServerSubControl(this, mobId), delayEvent);
        }
    }

    /** @private -- relayed from AVRServerGameControl when mob spawn is successful. */
    internal function mobSpawned_v1 (mobId :String) :void
    {
        // TODO: we should also report server-side MOB spawning errors to the game
        var delayEvent :Boolean = false;
        setMobSubControl(mobId, new MobServerSubControl(this, mobId), delayEvent);
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
