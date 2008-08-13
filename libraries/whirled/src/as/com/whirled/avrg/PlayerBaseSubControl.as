//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg {

import com.whirled.AbstractControl;
import com.whirled.TargetedSubControl;

/**
 * Dispatched when this player receives a coin payout.
 *
 * @eventType com.whirled.net.MessageReceivedEvent.COINS_AWARDED
 */
[Event(name="CoinsAwarded", type="com.whirled.avrg.AVRGameControlEvent")]

/**
 */
public class PlayerBaseSubControl extends TargetedSubControl
{
    /** @private */
    public function PlayerBaseSubControl (ctrl :AbstractControl, targetId :int = 0)
    {
        super(ctrl, targetId);
    }

    public function getPlayerId () :int
    {
        return callHostCode("getPlayerId_v1") as int;
    }

    public function completeTask (taskId :String, payout :Number) :Boolean
    {
        return callHostCode("completeTask_v1", taskId, payout);
    }

    /** @private */
    internal function coinsAwarded_v1 (amount :int) :void
    {
        // TODO: targetId
        dispatch(new AVRGameControlEvent(AVRGameControlEvent.COINS_AWARDED, null, amount));
    }
}
}
