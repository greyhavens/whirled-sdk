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
import com.whirled.contrib.platformer.PlatformerContext;

public class ThrottlingMessageManager extends MessageManager
{
    public function ThrottlingMessageManager (
            gameCtrl :GameControl, rate :int, keepAlive :int = DEFAULT_KEEP_ALIVE)
    {
        super(gameCtrl);
        _minRate = rate;
        _timer = new Timer(rate);
        _timer.addEventListener(TimerEvent.TIMER, onTimer);
        _timer.start();
        _lastSent = getTimer();
        _keepAlive = DEFAULT_KEEP_ALIVE;
    }

    public function trackRateAgainstId (
            tracker :String = null, adjustRate :int = 0, maxRate :int = 0) :void
    {
        if (_tracker != tracker) {
            if (_tracker != null) {
                _gameCtrl.services.stopTicker(_tracker);
            }
            _tracker = tracker;
            if (_tracker != null) {
                _gameCtrl.services.startTicker(_tracker, TRACK_RATE);
            }
        }

        _lastTrackAdjust = getTimer();
        _trackReceived = 0;
        _trackAdjustRate = adjustRate;
        _maxRate = maxRate;
    }

    public function flushQueue () :void
    {
        if (_queue.msgs != null) {
            super.sendMessage(_queue);
            _queue = new QueueMessage();
            _lastSent = getTimer();
        }
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
        flushQueue();
        if (!PlatformerContext.gctrl.game.amServerAgent() && getTimer() - _lastSent > _keepAlive) {
            _gameCtrl.net.sendMessage("ping", null);
            trace("sending Ping");
            _lastSent = getTimer();
        }
        if (_tracker != null) {
            var diff :int = getTimer() - _lastTrackAdjust;
            if (diff > _trackAdjustRate) {
                var rate :int;
                if (_trackReceived == 0) {
                    rate = _maxRate;
                } else {
                    rate = Math.round(diff * _minRate / _trackReceived / TRACK_RATE);
                    rate = Math.min(_maxRate, Math.max(_minRate, rate));
                }
                //trace("Adjusting throttle rate to: " + rate);
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
        if (_tracker != null && e.name == _tracker) {
            _trackReceived++;
        } else {
            super.onMessageReceived(e);
        }
    }

    protected var _queue :QueueMessage = new QueueMessage();
    protected var _timer :Timer;
    protected var _lastSent :int;
    protected var _maxRate :int;
    protected var _minRate :int;
    protected var _tracker :String;
    protected var _lastTrackAdjust :int;
    protected var _trackReceived :int;
    protected var _trackAdjustRate :int;
    protected var _keepAlive :int;

    protected static const TRACK_RATE :int = 300;
    protected static const DEFAULT_KEEP_ALIVE :int = 10000;
}
}
