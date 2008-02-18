package com.whirled.contrib.core.tasks {

import com.threerings.util.Assert;

import com.whirled.contrib.core.SimObject;
import com.whirled.contrib.core.ObjectTask;
import com.whirled.contrib.core.ObjectMessage;

import com.whirled.contrib.core.util.Interpolator;
import com.whirled.contrib.core.util.MXInterpolatorAdapter;

import flash.geom.Point;

import mx.effects.easing.*;
import flash.display.DisplayObject;
import com.whirled.contrib.core.components.RotationComponent;

public class RotationTask
    implements ObjectTask
{
    public static function CreateLinear (rotationDegrees :Number, time :Number) :RotationTask
    {
        return new RotationTask(
            rotationDegrees,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Linear.easeNone));
    }

    public static function CreateSmooth (rotationDegrees :Number, time :Number) :RotationTask
    {
        return new RotationTask(
            rotationDegrees,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Cubic.easeInOut));
    }

    public static function CreateEaseIn (rotationDegrees :Number, time :Number) :RotationTask
    {
        return new RotationTask(
            rotationDegrees,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Cubic.easeIn));
    }

    public static function CreateEaseOut (rotationDegrees :Number, time :Number) :RotationTask
    {
        return new RotationTask(
            rotationDegrees,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Cubic.easeOut));
    }

    public function RotationTask (
        rotationDegrees :Number,
        time :Number = 0,
        interpolator :Interpolator = null)
    {
        // default to linear interpolation
        if (null == interpolator) {
            interpolator = new MXInterpolatorAdapter(mx.effects.easing.Linear.easeNone);
        }

        _to = rotationDegrees;
        _totalTime = Math.max(time, 0);
        _interpolator = interpolator;
    }

    public function update (dt :Number, obj :SimObject) :Boolean
    {
        var rotationComponent :RotationComponent = (obj as RotationComponent);
        
        if (null == rotationComponent) {
            throw new Error("RotationTask can only be applied to SimObjects that implement RotationComponent");
        }

        if (0 == _elapsedTime) {
            _from = rotationComponent.rotation;
        }

        _elapsedTime += dt;

        rotationComponent.rotation = _interpolator.interpolate(_from, _to, _elapsedTime, _totalTime);

        return (_elapsedTime >= _totalTime);
    }

    public function clone () :ObjectTask
    {
        return new RotationTask(_to, _totalTime, _interpolator);
    }

    public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        return false;
    }

    protected var _interpolator :Interpolator;

    protected var _to :Number;
    protected var _from :Number;

    protected var _totalTime :Number = 0;
    protected var _elapsedTime :Number = 0;
}

}
