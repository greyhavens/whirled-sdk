//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg {

import com.threerings.util.Log;

import com.whirled.AbstractControl;
import com.whirled.AbstractSubControl;

/**
 * Defines actions, accessors and callbacks available to all MOBs.
 */
public class MobBaseSubControl extends AbstractSubControl
{
    public function MobBaseSubControl (ctrl :AbstractControl, id :String)
    {
        super(ctrl);
        _id = id;
    }

    /** @private */
    internal function appearanceChanged (
        location :Array, orient :Number, moving :Boolean, sleeping :Boolean) :void
    {
        _location = location;
        _orient = orient;
        _isMoving = moving;
        // "sleeping" is ignored in this class
        dispatch(new AVRGameControlEvent(AVRGameControlEvent.MOB_APPEARANCE_CHANGED));
    }

    /** @private */
    protected var _id :String;

    /** Our current orientation, or 0. @private */
    protected var _orient :Number = 0;

    /** Indicates whether or not we're currently moving. @private */
    protected var _isMoving :Boolean;

    /** Contains our current location in the scene [x, y, z], or null. @private */
    protected var _location :Array;
}
}
