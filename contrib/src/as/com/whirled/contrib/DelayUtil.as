// $Id$

package com.whirled.contrib {

import flash.events.Event;
import flash.events.IEventDispatcher;

/**
 * A simple utility class for delaying some action by any number of seconds or frames.
 */
public class DelayUtil 
{
    public static const SECONDS :int = 1;
    public static const FRAMES :int = 2;

    /** 
     * init must be called before DelayUtil can function.  The dispatcher that is passed in must
     * be a display object on that will remain on the display list, as the DisplayUtil needs
     * constant ENTER_FRAME events in order to function.
     */
    public static function init (dispatcher :IEventDispatcher) :void
    {
        EventHandlers.registerEventListener(dispatcher, Event.ENTER_FRAME, enterFrame);
    }

    /**
     * @param type either SECONDS or FRAMES
     * @param count the number of SECONDS or FRAMES to wait
     * @param callback a function that takes no parameters that will be called after the 
     *                 specified delay.
     */
    public static function delay (type :int, count :int, callback :Function) :void
    {
        switch (type) {
        case (SECONDS): _delayers.push(new SecondDelayer(count, callback)); break;
        case (FRAMES): _delayers.push(new FrameDelayer(count, callback)); break;
        }
    }

    protected static function enterFrame (event :Event) :void
    {
        for (var ii :int = 0; ii < _delayers.length; ii++) {
            if ((_delayers[ii] as Delayer).tick()) {
                _delayers.splice(ii, 1);
                ii--;
            }
        }
    }

    protected static var _delayers :Array = [];
}
}

import flash.utils.getTimer; // function import

class Delayer
{
    public function Delayer (count :int, callback :Function) 
    {
        _count = count;
        _callback = callback;
    }

    public function tick () :Boolean
    {
        // NOOP
        return true;
    }

    protected var _count :int;
    protected var _callback :Function;
}

class SecondDelayer extends Delayer
{
    public function SecondDelayer (count :int, callback :Function)
    {
        super(count, callback);
        _startTime = getTimer();
    }

    override public function tick () :Boolean
    {
        if (getTimer() - _startTime >= _count * 1000) {
            _callback();
            return true;
        }
        return false;
    }

    protected var _startTime :int;
}

class FrameDelayer extends Delayer
{
    public function FrameDelayer (count :int, callback :Function)
    {
        super(count, callback);
    }

    override public function tick () :Boolean
    {
        _count--;
        if (_count == 0) {
            _callback();
            return true;
        }
        return false;
    }
}
