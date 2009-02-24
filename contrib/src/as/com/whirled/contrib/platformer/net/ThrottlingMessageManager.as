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

package com.whirled.contrib.platformer.net {

import flash.events.TimerEvent;
import flash.utils.Timer;
import flash.utils.getTimer;

import com.whirled.game.GameControl;
import com.whirled.net.MessageReceivedEvent;

public class ThrottlingMessageManager extends MessageManager
{
    public static const DEBUG :Boolean = false;

    public function ThrottlingMessageManager (gameCtrl :GameControl, rate :int)
    {
        super(gameCtrl);
        _minRate = rate;
        _timer = new Timer(rate);
        _timer.addEventListener(TimerEvent.TIMER, onTimer);
        _timer.start();
        _lastSent = getTimer();
    }

    public function trackRateAgainstId (id :int = 0, adjustRate :int = 0, maxRate :int = 0) :void
    {
        _trackingId = id;
        _lastTrackAdjust = getTimer();
        _trackReceived = 0;
        _trackAdjustRate = adjustRate;
        _maxRate = maxRate;
    }

    override public function shutdown () :void
    {
        _timer.stop();
        _timer.removeEventListener(TimerEvent.TIMER, onTimer);
    }

    override public function sendMessage (msg :GameMessage) :void
    {
        checkSend(msg);

        _queue.addMessage(msg);
    }

    protected function onTimer (... ignored) :void
    {
        if (_queue.msgs != null) {
            super.sendMessage(_queue);
            _queue = new QueueMessage();
            if (DEBUG) {
                _sent++;
                if (_sent == 10) {
                    var now :int = getTimer();
                    trace("sent 10 messages in " + (now - _lastSent));
                    _lastSent = now;
                    _sent = 0;
                }
            }
        }
        if (_trackingId != 0) {
            var diff :int = getTimer() - _lastTrackAdjust;
            if (diff > _trackAdjustRate) {
                var rate :int;
                if (_trackReceived == 0) {
                    rate = _maxRate;
                } else {
                    rate = Math.round(diff / _trackReceived);
                    rate = Math.min(_maxRate, Math.max(_minRate, rate));
                }
                _timer.delay = rate;
                _lastTrackAdjust = getTimer();
                _trackReceived = 0;
            }
        } else if (_timer.delay != _minRate) {
            _timer.delay = _minRate;
        }
    }

    override protected function onMessageReceived (e :MessageReceivedEvent) :void
    {
        if (_trackingId != 0 && _trackingId == e.senderId) {
            _trackReceived++;
        }
        super.onMessageReceived(e);
    }

    protected var _queue :QueueMessage = new QueueMessage();
    protected var _timer :Timer;
    protected var _sent :int;
    protected var _lastSent :int;
    protected var _maxRate :int;
    protected var _minRate :int;
    protected var _trackingId :int;
    protected var _lastTrackAdjust :int;
    protected var _trackReceived :int;
    protected var _trackAdjustRate :int;
}
}
