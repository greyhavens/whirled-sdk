package com.whirled.contrib.core.tasks {

import com.threerings.util.Assert;
import com.whirled.contrib.core.SimObject;
import com.whirled.contrib.core.ObjectMessage;
import com.whirled.contrib.core.ObjectTask;
import com.whirled.contrib.core.components.AlphaComponent;
import com.whirled.contrib.core.util.Interpolator;
import com.whirled.contrib.core.util.MXInterpolatorAdapter;

import mx.effects.easing.*;

public class AlphaTask
    implements ObjectTask
{
    public static function CreateLinear (alpha :Number, time :Number) :AlphaTask
    {
        return new AlphaTask(
            alpha,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Linear.easeNone));
    }

    public static function CreateSmooth (alpha :Number, time :Number) :AlphaTask
    {
        return new AlphaTask(
            alpha,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Cubic.easeInOut));
    }

    public static function CreateEaseIn (alpha :Number, time :Number) :AlphaTask
    {
        return new AlphaTask(
            alpha,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Cubic.easeIn));
    }

    public static function CreateEaseOut (alpha :Number, time :Number) :AlphaTask
    {
        return new AlphaTask(
            alpha,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Cubic.easeOut));
    }

    public function AlphaTask (
        alpha :Number,
        time :Number = 0,
        interpolator :Interpolator = null)
    {
        // default to linear interpolation
        if (null == interpolator) {
            interpolator = new MXInterpolatorAdapter(mx.effects.easing.Linear.easeNone);
        }

        _to = alpha;
        _totalTime = Math.max(time, 0);
        _interpolator = interpolator;
    }

    public function update (dt :Number, obj :SimObject) :Boolean
    {
        var alphaComponent :AlphaComponent = (obj as AlphaComponent);
        
        if (null == alphaComponent) {
            throw new Error("AlphaTask can only be applied to SimObjects that implement AlphaComponent");
        }
        
        if (0 == _elapsedTime) {
            _from = alphaComponent.alpha;
        }

        _elapsedTime += dt;

        alphaComponent.alpha = _interpolator.interpolate(_from, _to, _elapsedTime, _totalTime);

        return (_elapsedTime >= _totalTime);
    }

    public function clone () :ObjectTask
    {
        return new AlphaTask(_to, _totalTime, _interpolator);
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
