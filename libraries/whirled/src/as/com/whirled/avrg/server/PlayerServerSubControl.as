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

// TODO: We should probably dispatch message events here, too.
public class PlayerServerSubControl extends PlayerBaseSubControl
    implements MessageSubControl
{
    /** @private */
    public function PlayerServerSubControl (ctrl :AbstractControl, targetId :int)
    {
        super(ctrl, targetId);

        if (targetId != getPlayerId()) {
            throw new Error("Internal error [targetId=" + targetId + ", playerId=" +
                            getPlayerId + "]");
        }
    }

    public function get props () :PropertySubControl
    {
        return _props;
    }

    /** Sends a message to this player only. */
    public function sendMessage (name :String, value :Object) :void
    {
        callHostCode("player_sendMessage_v1", name, value);
    }

    /** @private */
    override protected function setUserProps (o :Object) :void
    {
        super.setUserProps(o);
    }

    /** @private */
    override protected function createSubControls () :Array
    {
        _props = new PropertySubControlImpl(
            _parent, 0, "player_propertyWasSet", "player_getGameData", "player_setProperty");
        return [ _props ];
    }

    protected var _props :PropertySubControl;
}
}
