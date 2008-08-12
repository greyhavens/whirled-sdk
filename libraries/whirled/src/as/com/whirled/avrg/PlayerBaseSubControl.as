//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg {

import com.whirled.AbstractControl;
import com.whirled.TargetedSubControl;

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
}
}
