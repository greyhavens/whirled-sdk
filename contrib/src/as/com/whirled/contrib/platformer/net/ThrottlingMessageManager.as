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

public class ThrottlingMessageManager extends MessageManager
{
    public static const DEBUG :Boolean = false;

    public function ThrottlingMessageManager (gameCtrl :GameControl, rate :int)
    {
        super(gameCtrl);
        _timer = new Timer(rate);
        _timer.addEventListener(TimerEvent.TIMER, onTimer);
        _timer.start();
        _lastSent = getTimer();
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
    }

    protected var _queue :QueueMessage = new QueueMessage();
    protected var _timer :Timer;
    protected var _sent :int;
    protected var _lastSent :int;
}
}
