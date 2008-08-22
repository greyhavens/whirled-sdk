//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg {

import com.whirled.AbstractControl;
import com.whirled.AbstractSubControl;

import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.MessageSubControl;

/**
 * This subcontrol is used by an AVRG on the client to send messages to the server agent.
 */
public class AgentSubControl extends AbstractSubControl
    implements MessageSubControl
{
    /** @private */
    public function AgentSubControl (ctrl :AbstractControl)
    {
        super(ctrl);
    }

    /**
     * Sends a message to the agent.
     */
    public function sendMessage (name :String, value :Object = null) :void
    {
        callHostCode("agent_sendMessage_v1", name, value);
    }

    /** @private */
    override protected function setUserProps (o :Object) :void
    {
        super.setUserProps(o);

        o["agent_messageReceived_v1"] = messageReceived;
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
