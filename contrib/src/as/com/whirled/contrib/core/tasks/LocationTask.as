package com.whirled.contrib.core.tasks {

import com.threerings.util.Assert;

import com.whirled.contrib.core.AppObject;
import com.whirled.contrib.core.ObjectTask;
import com.whirled.contrib.core.util.Interpolator;
import com.whirled.contrib.core.util.MXInterpolatorAdapter;

import flash.geom.Point;

import mx.effects.easing.*;
import flash.display.DisplayObject;
import com.whirled.contrib.core.components.LocationComponent;

public class LocationTask extends ObjectTask
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

        Assert.isTrue(time >= 0);

        _toX = x;
        _toY = y;
        _totalTime = time;
        _interpolator = interpolator;
    }

    override public function update (dt :Number, obj :AppObject) :Boolean
    {
        var lc :LocationComponent = (obj as LocationComponent);
        Assert.isNotNull(lc, "LocationTask can only be applied to AppObjects that implement LocationComponent.");

        if (0 == _elapsedTime) {
            _fromX = lc.x;
            _fromY = lc.y;
        }

        _elapsedTime += dt;

        lc.x = _interpolator.interpolate(_fromX, _toX, _elapsedTime, _totalTime);
        lc.y = _interpolator.interpolate(_fromY, _toY, _elapsedTime, _totalTime);

        return (_elapsedTime >= _totalTime);
    }

    override public function clone () :ObjectTask
    {
        return new LocationTask(_toX, _toY, _totalTime, _interpolator);
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
