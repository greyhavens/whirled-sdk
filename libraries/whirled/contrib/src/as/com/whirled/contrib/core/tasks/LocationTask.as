package com.whirled.contrib.core.tasks {

import com.threerings.util.Assert;

import com.whirled.contrib.core.SimObject;
import com.whirled.contrib.core.ObjectTask;
import com.whirled.contrib.core.util.Interpolator;
import com.whirled.contrib.core.util.MXInterpolatorAdapter;

import flash.geom.Point;

import mx.effects.easing.*;
import flash.display.DisplayObject;
import com.whirled.contrib.core.components.LocationComponent;
import com.whirled.contrib.core.ObjectMessage;

public class LocationTask
    implements ObjectTask
{
    public static function CreateLinear (x :Number, y :Number, time :Number) :LocationTask
    {
        return new LocationTask(
            x, y,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Linear.easeNone));
    }

    public static function CreateSmooth (x :Number, y :Number, time :Number) :LocationTask
    {
        return new LocationTask(
            x, y,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Cubic.easeInOut));
    }

    public static function CreateEaseIn (x :Number, y :Number, time :Number) :LocationTask
    {
        return new LocationTask(
            x, y,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Cubic.easeIn));
    }

    public static function CreateEaseOut (x :Number, y :Number, time :Number) :LocationTask
    {
        return new LocationTask(
            x, y,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Cubic.easeOut));
    }

    public static function CreateWithFunction (x :Number, y:Number, time :Number, fn :Function) :LocationTask
    {
        return new LocationTask(
           x, y,
           time,
           new MXInterpolatorAdapter(fn));
    }

    public function LocationTask (
        x :Number,
        y :Number,
        time :Number = 0,
        interpolator :Interpolator = null)
    {
        // default to linear interpolation
        if (null == interpolator) {
            interpolator = new MXInterpolatorAdapter(mx.effects.easing.Linear.easeNone);
        }

        _toX = x;
        _toY = y;
        _totalTime = Math.max(time, 0);
        _interpolator = interpolator;
    }

    public function update (dt :Number, obj :SimObject) :Boolean
    {
        var lc :LocationComponent = (obj as LocationComponent);
        
        if (null == lc) {
            throw new Error("LocationTask can only be applied to SimObjects that implement LocationComponent");
        }

        if (0 == _elapsedTime) {
            _fromX = lc.x;
            _fromY = lc.y;
        }

        _elapsedTime += dt;

        lc.x = _interpolator.interpolate(_fromX, _toX, _elapsedTime, _totalTime);
        lc.y = _interpolator.interpolate(_fromY, _toY, _elapsedTime, _totalTime);

        return (_elapsedTime >= _totalTime);
    }

    public function clone () :ObjectTask
    {
        return new LocationTask(_toX, _toY, _totalTime, _interpolator);
    }

    public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        return false;
    }

    protected var _interpolator :Interpolator;

    protected var _toX :Number;
    protected var _toY :Number;

    protected var _fromX :Number;
    protected var _fromY :Number;

    protected var _totalTime :Number = 0;
    protected var _elapsedTime :Number = 0;
}

}