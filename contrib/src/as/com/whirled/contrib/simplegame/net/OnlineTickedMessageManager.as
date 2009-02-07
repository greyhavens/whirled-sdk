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

package com.whirled.contrib.simplegame.net {

import com.threerings.util.HashMap;
import com.threerings.util.Log;
import com.whirled.contrib.EventHandlerManager;
import com.whirled.game.GameControl;
import com.whirled.game.NetSubControl;
import com.whirled.net.MessageReceivedEvent;

import flash.utils.ByteArray;
import flash.utils.getTimer;

/**
 * A simple manager for sending and receiving messages on an established timeslice boundary.
 * Received messages are grouped by "ticks", which represent timeslices, and are synchronized
 * across clients by a game server.
 */
public class OnlineTickedMessageManager
    implements TickedMessageManager
{
    public function OnlineTickedMessageManager (gameCtrl :GameControl, isInControl :Boolean,
        tickIntervalMS :int, tickMessageName :String = "t")
    {
        _gameCtrl = gameCtrl;
        _isInControl = isInControl;
        _tickIntervalMS = tickIntervalMS;
        _tickName = tickMessageName;
    }

    public function addMessageType (messageClass :Class) :void
    {
        var msg :Message = new messageClass();
        if (_messageTypes.put(msg.name, messageClass) !== undefined) {
            throw new Error("Message type '" + msg.name + "' already registered");
        }
    }

    public function run () :void
    {
        _events.registerListener(_gameCtrl.net, MessageReceivedEvent.MESSAGE_RECEIVED,
            onMessageReceived);

        _ticks = [];
        _pendingSends = [];

        // The in-control player (or server) is in charge of starting the ticker
        if (_isInControl) {
            _gameCtrl.services.startTicker(_tickName, _tickIntervalMS);
        }
    }

    public function stop () :void
    {
        _ticks = null;
        _pendingSends = null;
        _receivedFirstTick = false;

        _events.freeAllHandlers();
    }

    public function get isReady () :Boolean
    {
        return _receivedFirstTick;
    }

    protected function onMessageReceived (event :MessageReceivedEvent) :void
    {
        var name :String = event.name;

        if (name == _tickName) {
            _ticks.push(new Array());
            _receivedFirstTick = true;

        } else if (_receivedFirstTick) {
            // add any actions received during this tick
            var array :Array = (_ticks[_ticks.length - 1] as Array);
            var msg :Message = deserializeMessage(event.name, event.value);

            if (null != msg) {
                array.push(msg);
            }
        }
    }

    public function get unprocessedTickCount () :uint
    {
        return (0 == _ticks.length ? 0 : _ticks.length - 1);
    }

    public function getNextTick () :Array
    {
        if(_ticks.length <= 1) {
            return null;
        } else {
            return (_ticks.shift() as Array);
        }
    }

    public function sendMessage (
            msg :Message, playerId :int = 0 /* == NetSubControl.TO_ALL */) :void
    {
        // do we need to queue this message?
        var addToQueue :Boolean = ((_pendingSends.length > 0) || (!canSendMessageNow()));

        if (addToQueue) {
            _pendingSends.push(msg);
            _pendingSends.push(playerId);
        } else {
            sendMessageNow(msg, playerId);
        }
    }

    protected function canSendMessageNow () :Boolean
    {
        return ((getTimer() - _lastSendTime) >= _minSendDelayMS);
    }

    protected function deserializeMessage (name :String, val :Object) :Message
    {
        var messageClass :Class = _messageTypes.get(name) as Class;
        if (null == messageClass) {
            //log.info("Discarding incoming '" + name + "' message (message type not registered)");
            return null;
        }

        var msg :Message = new messageClass();
        try {
            msg.fromBytes(ByteArray(val));
        } catch (e :Error) {
            log.warning("Discarding incoming '" + name + "' message (failed to deserialize)", e);
            return null;
        }

        return msg;
    }

    protected function sendMessageNow (msg :Message, playerId :int) :void
    {
        _gameCtrl.net.sendMessage(msg.name, msg.toBytes(), playerId);
        _lastSendTime = getTimer();
    }

    public function update (dt :Number) :void
    {
        // if there are messages waiting to go out, send one
        if (_pendingSends.length > 0 && canSendMessageNow()) {
            var message :Message = (_pendingSends.shift() as Message);
            var toPlayer :int = (_pendingSends.shift() as int);
            sendMessageNow(message, toPlayer);
        }
    }

    public function canSendMessage () :Boolean
    {
        // messages are stored in _pendingSends as two objects - data and playerId
        return (_pendingSends.length < (_maxPendingSends * 2));
    }

    public function set maxPendingSends (val :uint) :void
    {
        _maxPendingSends = val;
    }

    public function set maxSendsPerSecond (val :uint) :void
    {
        _minSendDelayMS = (0 == val ? 0 : (1000 / val) + 5);
    }

    protected var _isInControl :Boolean;
    protected var _tickIntervalMS :uint;

    protected var _gameCtrl :GameControl;
    protected var _tickName :String;
    protected var _receivedFirstTick :Boolean;
    protected var _ticks :Array;
    protected var _pendingSends :Array;
    protected var _maxPendingSends :uint = 10;
    protected var _minSendDelayMS :uint = 105;  // default to 10 sends/second
    protected var _lastSendTime :int;
    protected var _messageTypes :HashMap = new HashMap();

    protected var _events :EventHandlerManager = new EventHandlerManager();

    protected static const log :Log = Log.getLog(OnlineTickedMessageManager);
}

}
