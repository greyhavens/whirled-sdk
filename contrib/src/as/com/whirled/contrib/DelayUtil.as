// Whirled contrib library - tools for developing whirled games
// http://www.whirled.com/code/contrib/asdocs
//
// This library is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library.  If not, see <http://www.gnu.org/licenses/>.
//
// Copyright 2008 Three Rings Design
//
// $Id$

package com.whirled.contrib {

import com.threerings.util.EventHandlerManager;

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
     *
     * If an EventHandlerManager is provided, it will be used to register the event.  Otherwise
     * EventHandlers is used statically.
     */
    public static function init (
        dispatcher :IEventDispatcher, eventMgr :EventHandlerManager = null) :void
    {
        eventMgr = eventMgr != null ? eventMgr : EventHandlers.getGlobalManager();
        eventMgr.registerListener(dispatcher, Event.ENTER_FRAME, enterFrame);
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
        _endTime = getTimer() + (_count * 1000);
    }

    override public function tick () :Boolean
    {
        if (getTimer() > _endTime) {
            _callback();
            return true;
        }
        return false;
    }

    protected var _endTime :int;
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
