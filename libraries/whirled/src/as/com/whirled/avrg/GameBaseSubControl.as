//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg {

import com.whirled.AbstractControl;
import com.whirled.AbstractSubControl;
import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.impl.PropertyGetSubControlImpl;

/**
 * Dispatched when a message arrives with information that is not part of the shared game state.
 *
 * @eventType com.whirled.net.MessageReceivedEvent.MESSAGE_RECEIVED
 */
[Event(name="MsgReceived", type="com.whirled.net.MessageReceivedEvent")]

/**
 */
public class GameBaseSubControl extends AbstractSubControl
{
    /** @private */
    public function GameBaseSubControl (ctrl :AbstractControl)
    {
        super(ctrl);
    }

    public function getPlayerIds () :Array
    {
        return callHostCode("game_getPlayerIds_v1") as Array;
    }

    /** @private */
    override protected function setUserProps (o :Object) :void
    {
        super.setUserProps(o);

        o["game_messageReceived_v1"] = messageReceived;

        // neither backend sends in targetId for game
        o["game_propertyWasSet_v1"] = internalProps().propertyWasSet_v1;
    }

    /** @private */
    protected function messageReceived (name :String, value :Object, sender :int) :void
    {
        dispatch(new MessageReceivedEvent(0, name, value, sender));
    }

    protected function internalProps () :PropertyGetSubControlImpl
    {
        throw new Error("abstract");
    }
}
}
