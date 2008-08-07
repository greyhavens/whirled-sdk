//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg {

import com.whirled.AbstractControl;
import com.whirled.AbstractSubControl;
import com.whirled.game.PropertyGetSubControl;
import com.whirled.game.PropertyGetSubControlImpl;

/**
 */
public class PlayerSubControl extends AbstractSubControl
{
    /** @private */
    public function PlayerSubControl (ctrl :AbstractControl)
    {
        super(ctrl);
    }

    public function get props () :PropertyGetSubControl
    {
        return _props;
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
    override protected function setUserProps (o :Object) :void
    {
        super.setUserProps(o);
    }

    /** @private */
    override protected function createSubControls () :Array
    {
        return [
            _props = new PropertyGetSubControlImpl(_parent, "P")
            ];
    }

    protected var _props :PropertyGetSubControl;
}
}
