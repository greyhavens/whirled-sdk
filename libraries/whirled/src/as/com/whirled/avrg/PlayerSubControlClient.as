//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg {

import com.whirled.AbstractControl;
import com.whirled.AbstractSubControl;
import com.whirled.TargetedSubControl;
import com.whirled.net.MessageReceivedEvent;

/**
 */
public class PlayerSubControlClient extends PlayerSubControlBase
{
    /** @private */
    public function PlayerSubControlClient (ctrl :AbstractControl)
    {
        super(ctrl, 0);
    }

    public function getPlayerId () :int
    {
        return callHostCode("getPlayerId_v1");
    }

    /** @private */
    override protected function setUserProps (o :Object) :void
    {
        super.setUserProps(o);

        o["taskCompleted_v1"] = taskCompleted_v1;

        // the client backend does not send in targetId
        o["player_propertyWasSet_v1"] = _props.propertyWasSet_v1;

        o["player_messageReceived_v1"] = player_messageReceived_v1;
    }

    private function player_messageReceived_v1 (name :String, value :Object, sender :int) :void
    {
        dispatch(new MessageReceivedEvent(_targetId, name, value, sender));
    }
}
}
