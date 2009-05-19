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

import com.threerings.util.ArrayUtil;

import flash.events.TimerEvent;
import flash.utils.Timer;

/**
 * A class for managing a group of timers.
 */
public class TimerManager
{
    /**
     * Constructs a new TimerManager.
     *
     * @param parent (optional) if not null, this TimerManager will become a child of
     * the specified parent TimerManager. If the parent is shutdown, or its cancelAllTimers()
     * function is called, this TimerManager will be similarly affected.
     */
    public function TimerManager (parent :TimerManager = null)
    {
        if (parent != null) {
            _parent = parent;
            parent._children.push(this);
        }
    }

    /**
     * Cancels all running timers, and disconnects the TimerManager from its parent, if it has one.
     * All child TimerManagers will be shutdown as well.
     *
     * It's an error to call any function on TimerManager after shutdown() has been called.
     */
    public function shutdown () :void
    {
        // detach from our parent, if we have one
        if (_parent != null) {
            ArrayUtil.removeFirst(_parent._children, this);
        }

        // shutdown our children
        for each (var child :TimerManager in _children) {
            child._parent = null;
            child.shutdown();
        }

        cancelAllTimers();

        // null out internal state so that future calls to this TimerManager will
        // immediately NPE
        _parent = null;
        _children = null;
        _timers = null;
        _freeSlots = null;
    }

    /**
     * Creates and runs a timer that will run once, and clean up after itself.
     */
    public function runOnce (delay :Number, callback :Function) :void
    {
        var timer :ManagedTimer = createTimer(delay, 1,
            function (e :TimerEvent) :void {
                timer.cancel();
                callback(e);
            });

        timer.start();
    }

    /**
     * Creates and runs a timer that will run forever, or until canceled.
     */
    public function runForever (delay :Number, callback :Function) :ManagedTimer
    {
        var timer :ManagedTimer = createTimer(delay, 0, callback);
        timer.start();
        return timer;
    }

    /**
     * Creates, but doesn't run, a new ManagedTimer.
     */
    public function createTimer (delay :Number, repeatCount :int, timerCallback :Function = null,
        completeCallback :Function = null) :ManagedTimer
    {
        var managedTimer :ManagedTimerImpl = new ManagedTimerImpl();
        managedTimer.mgr = this;
        managedTimer.timer = new Timer(delay, repeatCount);

        if (timerCallback != null) {
            managedTimer.timer.addEventListener(TimerEvent.TIMER, timerCallback);
            managedTimer.timerCallback = timerCallback;
        }

        if (completeCallback != null) {
            managedTimer.timer.addEventListener(TimerEvent.TIMER_COMPLETE, completeCallback);
            managedTimer.completeCallback = completeCallback;
        }

        if (_freeSlots.length > 0) {
            var slot :int = int(_freeSlots.pop());
            _timers[slot] = managedTimer;
            managedTimer.slot = slot;

        } else {
            _timers.push(managedTimer);
            managedTimer.slot = _timers.length - 1;
        }

        return managedTimer;
    }

    /**
     * Stops all timers being managed by this TimerManager.
     * All child TimerManagers will have their timers stopped as well.
     */
    public function cancelAllTimers () :void
    {
        for each (var timer :ManagedTimerImpl in _timers) {
            // we can have holes in the _timers array
            if (timer != null) {
                stopTimer(timer);
            }
        }

        _timers = [];
        _freeSlots = [];

        for each (var child :TimerManager in _children) {
            child.cancelAllTimers();
        }
    }

    /**
     * Cancels a single running ManagedTimer. The timer must have been created by this
     * TimerManager.
     */
    public function cancelTimer (timer :ManagedTimer) :void
    {
        var managedTimer :ManagedTimerImpl = ManagedTimerImpl(timer);
        var slot :int = managedTimer.slot;
        stopTimer(managedTimer);
        _timers[slot] = null;
        _freeSlots.push(slot);
    }

    protected function stopTimer (managedTimer :ManagedTimerImpl) :void
    {
        if (managedTimer.mgr != this) {
            throw new Error("timer is not managed by this TimerManager");
        }

        if (managedTimer.timerCallback != null) {
            managedTimer.timer.removeEventListener(TimerEvent.TIMER, managedTimer.timerCallback);
        }

        if (managedTimer.completeCallback != null) {
            managedTimer.timer.removeEventListener(TimerEvent.TIMER_COMPLETE,
                managedTimer.completeCallback);
        }

        managedTimer.timer.stop();
        managedTimer.timer = null;
        managedTimer.mgr = null;
    }

    protected var _timers :Array = [];
    protected var _freeSlots :Array = [];

    protected var _parent :TimerManager;
    protected var _children :Array = [];
}

}

import flash.utils.Timer;
import com.whirled.contrib.ManagedTimer;
import com.whirled.contrib.TimerManager;

class ManagedTimerImpl
    implements ManagedTimer
{
    public var mgr :TimerManager;
    public var timer :Timer;
    public var timerCallback :Function;
    public var completeCallback :Function;
    public var slot :int;

    public function cancel () :void
    {
        mgr.cancelTimer(this);
    }

    public function reset () :void
    {
        timer.reset();
    }

    public function start () :void
    {
        timer.start();
    }

    public function stop () :void
    {
        timer.stop();
    }

    public function get currentCount () :int
    {
        return timer.currentCount;
    }

    public function get delay () :Number
    {
        return timer.delay;
    }

    public function set delay (val :Number) :void
    {
        timer.delay = val;
    }

    public function get repeatCount () :int
    {
        return timer.repeatCount;
    }

    /*public function set repeatCount (val :int) :void
    {
        timer.repeatCount = val;
    }*/

    public function get running () :Boolean
    {
        return timer.running;
    }
}
