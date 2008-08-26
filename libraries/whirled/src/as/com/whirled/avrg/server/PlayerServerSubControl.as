//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg.server {

import com.whirled.AbstractControl;

import com.whirled.avrg.PlayerBaseSubControl;

import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.MessageSubControl;
import com.whirled.net.PropertySubControl;
import com.whirled.net.impl.PropertySubControlImpl;

public class PlayerServerSubControl extends PlayerBaseSubControl
    implements MessageSubControl
{
    /** @private */
    public function PlayerServerSubControl (ctrl :AbstractControl, targetId :int)
    {
        super(ctrl, targetId);
    }

    /** Sends a message to this player only. */
    public function sendMessage (name :String, value :Object = null) :void
    {
        callHostCode("player_sendMessage_v1", name, value);
    }

    /** @private */
    internal function leftRoom () :void
    {
        super.leftRoomProtected();
    }

    /** @private */
    internal function enteredRoom (newScene :int) :void
    {
        super.enteredRoomProtected(newScene);
    }

    internal function gotHostPropsFriend (o :Object) :void
    {
        gotHostProps(o);
    }
}
}
