//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg.server {

import com.whirled.AbstractControl;

import com.whirled.avrg.GameBaseSubControl;

import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.MessageSubControl;
import com.whirled.net.PropertySubControl;
import com.whirled.net.impl.PropertyGetSubControlImpl;

import com.whirled.net.impl.PropertySubControlImpl;
public class GameServerSubControl extends GameBaseSubControl
    implements MessageSubControl
{
    /** @private */
    public function GameServerSubControl (ctrl :AbstractControl)
    {
        super(ctrl);
    }

    public function get props () :PropertySubControl
    {
        return _props;
    }

    /** Sends a message to all players in this instance. use carefully if instanceId == 0 */
    public function sendMessage (name :String, value :Object = null) :void
    {
        callHostCode("game_sendMessage_v1", name, value);
    }

    /** @private */
    override protected function createSubControls () :Array
    {
        _props = new PropertySubControlImpl(
            _parent, 0, "game_getGameData_v1", "game_setProperty_v1");
        return [ _props ];
    }

    override protected function internalProps () :PropertyGetSubControlImpl
    {
        return _props;
    }

    protected var _props :PropertySubControlImpl;
}
}
