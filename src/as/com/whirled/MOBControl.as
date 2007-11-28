//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled {

import flash.display.DisplayObject;

/**
 * Defines actions, accessors and callbacks available to all MOBs.
 */
public class MobControl extends WhirledSubControl
{
    public function MobControl (ctrl :AVRGameControl, id :String)
    {
        super(ctrl);
        _id = id;
    }

    /**
     * Called when we start or stop moving or change orientation.
     */
    public function appearanceChanged (
        location :Array, orient :Number, moving :Boolean, sleeping :Boolean) :void
    {
        _location = location;
        _orient = orient;
        _isMoving = moving;
        // "sleeping" is ignored in this class
        dispatchEvent(new ControlEvent(ControlEvent.APPEARANCE_CHANGED));
    }

    protected var _id :String;

    /** Our current orientation, or 0. */
    protected var _orient :Number = 0;

    /** Indicates whether or not we're currently moving. */
    protected var _isMoving :Boolean;

    /** Contains our current location in the scene [x, y, z], or null. */
    protected var _location :Array;
}
}
