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

    /**
     * Start the ticker with the specified name. The ticker will deliver messages
     * to all connected clients, at the specified delay. The value of each message is
     * a single integer, starting with 0 and increasing by 1 with each messsage.
     */
    public function startTicker (tickerName :String, msOfDelay :int) :void
    {
        callHostCode("setTicker_v1", tickerName, msOfDelay);
    }

    /**
     * Stop the specified ticker.
     */
    public function stopTicker (tickerName :String) :void
    {
        startTicker(tickerName, 0);
    }

    /** Sends a message to all players in this instance. use carefully if instanceId == 0 */
    public function sendMessage (name :String, value :Object) :void
    {
        callHostCode("game_sendMessage_v1", name, value);
    }

    /** @private */
    override protected function createSubControls () :Array
    {
        _props = new PropertySubControlImpl(
            _parent, 0, "game_propertyWasSet_v1", "game_getGameData_v1", "game_setProperty_v1");
        return [ _props ];
    }

    protected var _props :PropertySubControl;
}
}
