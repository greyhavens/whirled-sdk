//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg {

import com.whirled.AbstractControl;
import com.whirled.AbstractSubControl;

import com.whirled.TargetedSubControl;
import com.whirled.net.PropertyGetSubControl;
import com.whirled.net.impl.PropertyGetSubControlImpl;

/**
 */
public class PlayerSubControl extends PlayerBaseSubControl
{
    /** @private */
    public function PlayerSubControl (ctrl :AbstractControl, targetId :int = 0)
    {
        super(ctrl, targetId);
    }

    public function get props () :PropertyGetSubControl
    {
        return _props;
    }

    /** @private */
    override protected function createSubControls () :Array
    {
        _props = new PropertyGetSubControlImpl(
            _parent, _targetId, "player_propertyWasSet", "player_getGameData");
        return [ _props ];
    }

    /** @private */
    override protected function setUserProps (o :Object) :void
    {
        super.setUserProps(o);

        o["coinsAwarded_v1"] = coinsAwarded_v1;
    }

    protected var _props :PropertyGetSubControl;
}
}
