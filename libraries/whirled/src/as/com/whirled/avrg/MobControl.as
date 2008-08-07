//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg {

import flash.display.DisplayObject;

import com.threerings.util.Log;

import com.whirled.AbstractControl;
import com.whirled.AbstractSubControl;
import com.whirled.ControlEvent;

/**
 * Defines actions, accessors and callbacks available to all MOBs.
 */
public class MobControl extends AbstractSubControl
{
    public function MobControl (ctrl :AbstractControl, id :String)
    {
        super(ctrl);
        _id = id;
    }

    public function getAVRGameControl () :AVRGameControl
    {
        return AVRGameControl(_parent);
    }

    /**
     * Set the layout "hotspot" for your item, specified as pixels relative to (0, 0) the top-left
     * coordinate.
     *
     * If unset, the default hotspot will be based off of the SWF dimensions, with x = width / 2,
     * y = height.
     */
    public function setHotSpot (x :Number, y :Number, height :Number = NaN) :void
    {
        callHostCode("setMobHotSpot_v1", _id, x, y, height);
    }

    public function setDecoration (decoration :DisplayObject) :Boolean
    {
        if (_decoration == null) {
            _decoration = decoration;
            return callHostCode("setMobDecoration_v1", _id, _decoration, true);
        }
        return false;
    }

    public function removeDecoration () :Boolean
    {
        if (_decoration != null) {
            var oldDec :DisplayObject = _decoration;
            _decoration = null;
            return callHostCode("removeMobDecoration_v1", _id, oldDec, false);
        }
        return false;
    }

    // calls from AVRGameBackend

    /** @private */
    internal function appearanceChanged (
        location :Array, orient :Number, moving :Boolean, sleeping :Boolean) :void
    {
        _location = location;
        _orient = orient;
        _isMoving = moving;
        // "sleeping" is ignored in this class
        dispatch(new ControlEvent(ControlEvent.APPEARANCE_CHANGED));
    }

    /** @private */
    protected var _id :String;

    /** @private */
    protected var _decoration :DisplayObject;

    /** Our current orientation, or 0. @private */
    protected var _orient :Number = 0;

    /** Indicates whether or not we're currently moving. @private */
    protected var _isMoving :Boolean;

    /** Contains our current location in the scene [x, y, z], or null. @private */
    protected var _location :Array;
}
}
