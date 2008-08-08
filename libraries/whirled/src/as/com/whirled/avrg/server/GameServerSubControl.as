//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg.server {

import com.whirled.AbstractControl;

import com.whirled.avrg.GameSubControl;
import com.whirled.net.MessageSubControl;
import com.whirled.net.PropertyGetSubControl;
import com.whirled.net.impl.PropertyGetSubControlImpl;

/**
 */
public class GameServerSubControl extends GameSubControl
    implements MessageSubControl
{
    /** @private */
    public function GameServerSubControl (ctrl :AbstractControl)
    {
        super(ctrl);
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
    }

    /** @private */
    override protected function setUserProps (o :Object) :void
    {
        super.setUserProps(o);
    }

    /** @private */
    override protected function createSubControls () :Array
    {
        return super.createSubControls();
    }
}
}