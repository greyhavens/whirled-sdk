//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg.server {

import com.whirled.AbstractControl;

import com.whirled.avrg.GameSubControl;
import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.MessageSubControl;
import com.whirled.net.PropertyGetSubControl;
import com.whirled.net.impl.PropertyGetSubControlImpl;

/**
 * Dispatched when a message arrives for this game with information that is not part
 * of the shared game state.
 *
 * @eventType com.whirled.net.MessageReceivedEvent.MESSAGE_RECEIVED
 */
[Event(name="MsgReceived", type="com.whirled.net.MessageReceivedEvent")]

/** TODO: props needs to be PropertySubControl here, not PropertyGetSubControl */
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
        callHostCode("game_srv_sendMessage_v1", name, value);
    }

    /** @private */
    override protected function setUserProps (o :Object) :void
    {
        super.setUserProps(o);

        o["game_srv_messageReceived_v1"] = messageReceived;
    }

    /**
     * Private method to post a MessageReceivedEvent.
     */
    private function messageReceived (name :String, value :Object, sender :int) :void
    {
        dispatch(new MessageReceivedEvent(0, name, value, sender));
    }
}
}
