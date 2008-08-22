//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg {

import com.whirled.AbstractControl;

import com.whirled.net.PropertyGetSubControl;
import com.whirled.net.impl.PropertyGetSubControlImpl;

/**
 */
public class GameSubControl extends GameBaseSubControl
{
    /** @private */
    public function GameSubControl (ctrl :AbstractControl)
    {
        super(ctrl);
    }

    public function get props () :PropertyGetSubControl
    {
        return _props;
    }

    /** @private */
    override protected function createSubControls () :Array
    {
        _props = new PropertyGetSubControlImpl(_parent, 0, "game_getGameData_v1");
        return [ _props ];
    }

    override protected function internalProps () :PropertyGetSubControlImpl
    {
        return _props;
    }

    protected var _props :PropertyGetSubControlImpl;
}
}
