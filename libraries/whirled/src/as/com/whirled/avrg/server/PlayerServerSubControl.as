//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg.server {

import com.whirled.AbstractControl;

import com.whirled.avrg.PlayerSubControl;
import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.MessageSubControl;
import com.whirled.net.PropertyGetSubControl;
import com.whirled.net.impl.PropertyGetSubControlImpl;

/** TODO: props needs to be PropertySubControl here, not PropertyGetSubControl */
public class PlayerServerSubControl extends PlayerSubControl
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

    /** Sends a message to this player only. */
    public function sendMessage (name :String, value :Object) :void
    {
        callHostCode("player_srv_sendMessage_v1", name, value);
    }

    /** @private */
    override protected function setUserProps (o :Object) :void
    {
        super.setUserProps(o);
    }
}
}
