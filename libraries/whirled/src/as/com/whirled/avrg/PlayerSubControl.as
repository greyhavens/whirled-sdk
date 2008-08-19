//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg {

import com.whirled.AbstractControl;
import com.whirled.AbstractSubControl;

import com.whirled.TargetedSubControl;

/**
 */
public class PlayerSubControl extends PlayerBaseSubControl
{
    /** @private */
    public function PlayerSubControl (ctrl :AbstractControl, targetId :int = 0)
    {
        super(ctrl, targetId);
    }

    /** @private */
    override protected function setUserProps (o :Object) :void
    {
        super.setUserProps(o);

        o["coinsAwarded_v1"] = coinsAwarded_v1;
        o["leftRoom_v1"] = leftRoom_v1;
        o["enteredRoom_v1"] = enteredRoom_v1;
    }
}
}
