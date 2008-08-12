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
 * Defines actions, accessors and callbacks available on the client only.
 */
public class RoomSubControl extends RoomBaseSubControl
{
    /** @private */
    public function RoomSubControl (ctrl :AbstractControl, targetId :int = 0)
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
            _parent, _targetId, "room_propertyWasSet", "room_getGameData");
        return [ _props ];
    }

    protected var _props :PropertyGetSubControl;
}
}
