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
 * Defines actions, accessors and callbacks available to MOBs on the client.
 */
public class MobSubControl extends MobBaseSubControl
{
    public function MobSubControl (ctrl :AbstractControl, id :String, sprite :DisplayObject)
    {
        super(ctrl, id);
        _sprite = sprite;
    }

    public function getMobSprite () :DisplayObject
    {
        return _sprite;
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

    /** @private */
    protected var _sprite :DisplayObject;

    /** @private */
    protected var _decoration :DisplayObject;
}
}
