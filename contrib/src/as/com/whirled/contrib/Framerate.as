package com.whirled.contrib {

import flash.display.DisplayObject;
import flash.events.Event;
import flash.utils.getTimer;

public class Framerate
{
    public var fpsCur :Number = -1;
    public var fpsMean :Number = -1;
    public var fpsMin :Number = -1;
    public var fpsMax :Number = -1;

    public function Framerate (disp :DisplayObject, timeWindow :int = DEFAULT_TIME_WINDOW)
    {
        _fpsBuffer = new TimeBuffer(timeWindow, 128);
        _disp = disp;
        _disp.addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    public function shutdown () :void
    {
        _disp.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    protected function onEnterFrame (... ignored) :void
    {
        if (_lastTime < 0) {
            _lastTime = flash.utils.getTimer();
            return;
        }

        var time :int = flash.utils.getTimer();
        var dt :int = time - _lastTime;
        fpsCur = 1000 / dt;

        // calculate mean, min, max
        _fpsBuffer.push(fpsCur);
        var fpsSum :Number = 0;
        fpsMin = Number.MAX_VALUE;
        fpsMax = Number.MIN_VALUE;
        _fpsBuffer.forEach(function (num :Number, timestamp :int) :void {
            fpsSum += num;
            fpsMin = Math.min(fpsMin, num);
            fpsMax = Math.max(fpsMax, num);
        });
        fpsMean = fpsSum / _fpsBuffer.length;

        _lastTime = time;
    }

    protected var _fpsBuffer :TimeBuffer;
    protected var _disp :DisplayObject;

    protected var _lastTime :int = -1;

    protected static const DEFAULT_TIME_WINDOW :int = 5 * 1000; // 5 seconds
}

}
