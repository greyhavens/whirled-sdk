package com.whirled.contrib.simplegame.tasks {

import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.ObjectMessage;
import com.whirled.contrib.simplegame.ObjectTask;
import com.whirled.contrib.simplegame.util.Interpolator;
import com.whirled.contrib.simplegame.util.MXInterpolatorAdapter;

import mx.effects.easing.*;

public class AnimateValueTask
    implements ObjectTask
{
    public static function CreateLinear (boxedValue :Object, targetValue :Number, time :Number) :AnimateValueTask
    {
        return new AnimateValueTask(
            boxedValue,
            targetValue,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Linear.easeNone));
    }

    public static function CreateSmooth (boxedValue :Object, targetValue :Number, time :Number) :AnimateValueTask
    {
        return new AnimateValueTask(
            boxedValue,
            targetValue,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Cubic.easeInOut));
    }

    public static function CreateEaseIn (boxedValue :Object, targetValue :Number, time :Number) :AnimateValueTask
    {
        return new AnimateValueTask(
            boxedValue,
            targetValue,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Cubic.easeIn));
    }

    public static function CreateEaseOut (boxedValue :Object, targetValue :Number, time :Number) :AnimateValueTask
    {
        return new AnimateValueTask(
            boxedValue,
            targetValue,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Cubic.easeOut));
    }

    public function AnimateValueTask (
        boxedValue :Object,
        targetValue :Number,
        time :Number = 0,
        interpolator :Interpolator = null)
    {
        if (null == boxedValue || !boxedValue.hasOwnProperty("value")) {
            throw new Error("boxedValue must be non null, and must contain a 'value' property");
        }
        
        // default to linear interpolation
        if (null == interpolator) {
            interpolator = new MXInterpolatorAdapter(mx.effects.easing.Linear.easeNone);
        }

        _to = targetValue;
        _totalTime = Math.max(time, 0);
        _interpolator = interpolator;
        _boxedValue = boxedValue;
    }

    public function update (dt :Number, obj :SimObject) :Boolean
    {
        if (0 == _elapsedTime) {
            _from = (_boxedValue.value as Number);
        }

        _elapsedTime += dt;

        _boxedValue.value = _interpolator.interpolate(_from, _to, _elapsedTime, _totalTime);

        return (_elapsedTime >= _totalTime);
    }

    public function clone () :ObjectTask
    {
        return new AnimateValueTask(_boxedValue, _to, _totalTime, _interpolator);
    }

    public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        return false;
    }

    protected var _interpolator :Interpolator;

    protected var _to :Number;
    protected var _from :Number;
    protected var _boxedValue :Object;

    protected var _totalTime :Number = 0;
    protected var _elapsedTime :Number = 0;
}

}
