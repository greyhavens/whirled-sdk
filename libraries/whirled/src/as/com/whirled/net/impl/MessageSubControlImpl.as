package com.whirled.net.impl {

import com.whirled.AbstractControl;
import com.whirled.AbstractSubControl;
import com.whirled.net.MessageSubControl;

import com.whirled.game.MessageReceivedEvent;
import com.whirled.game.NetSubControl;

/**
 * Dispatched when a message arrives with information that is not part of the shared game state.
 *
 * @eventType com.whirled.game.MessageReceivedEvent.MESSAGE_RECEIVED
 */
[Event(name="MsgReceived", type="com.whirled.game.MessageReceivedEvent")]

public class MessageSubControlImpl extends HookSubControl
    implements MessageSubControl
{
    public function MessageSubControlImpl (ctrl :AbstractControl, hookPrefix :String)
    {
        super(ctrl, hookPrefix);
    }

    /**
     * Send a "message" to other clients subscribed to the game.  These is similar to setting a
     * property, except that the value will not be saved- it will merely end up coming out as a
     * MessageReceivedEvent.
     *
     * @param messageName The message to send.
     * @param value The value to attach to the message.
     */
    public function sendMessage (messageName :String, value :Object) :void
    {
        callHostCode(_hookPrefix + "_sendMessage_v2", messageName, value);
    }

    /**
     * @private
     */
    override protected function setUserProps (o :Object) :void
    {
        super.setUserProps(o);

        o["messageReceived_v2"] = messageReceived_v2;
    }

    /**
     * Private method to post a MessageReceivedEvent.
     */
    private function messageReceived_v2 (name :String, value :Object, sender :int) :void
    {
        dispatch(new MessageReceivedEvent(name, value, sender));
    }
}
}
