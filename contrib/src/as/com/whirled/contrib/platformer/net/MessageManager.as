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

import flash.events.EventDispatcher;
import flash.utils.ByteArray;
import flash.utils.getTimer;

import com.threerings.util.Map;
import com.threerings.util.Maps;

import com.whirled.game.GameControl;
import com.whirled.net.MessageReceivedEvent;

import com.whirled.contrib.platformer.PlatformerContext;

public class MessageManager extends EventDispatcher
{
    public var recTicks :int;
    public var msgCount :int;

    public function MessageManager (gameCtrl :GameControl)
    {
        _gameCtrl = gameCtrl;
        _gameCtrl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, onMessageReceived);
        addMessageType(QueueMessage);
        _lastRec = getTimer();
    }

    public function shutdown () :void
    {
        _gameCtrl.net.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, onMessageReceived);
    }

    public function addMessageType (messageClass :Class) :void
    {
        if (_msgTypes.put(messageClass.NAME, messageClass) !== undefined) {
            throw new Error("can't add duplicate '" + messageClass.NAME + "' message type");
        }
    }

    public function sendMessage (msg :GameMessage) :void
    {
        checkSend(msg);

        _gameCtrl.net.sendMessage(msg.name, msg.toBytes());
    }

    /**
     * Sends the GameMessage if the game isn't run locally.
     */
    public function notLocalSend (createMsg :Function, ...args) :void
    {
        if (!PlatformerContext.local) {
            sendMessage(createMsg.apply(NaN, args));
        }
    }

    /**
     * Sends the GameMessage only if being run on the server.
     */
    public function ifServerSend (createMsg :Function, ...args) :void
    {
        if (PlatformerContext.gctrl.game.amServerAgent()) {
            sendMessage(createMsg.apply(NaN, args));
        }
    }

    public function getMessage (name :String, bytes :ByteArray) :GameMessage
    {
        var msgClass :Class = _msgTypes.get(name);
        var msg :GameMessage;
        if (msgClass != null) {
            msg = new msgClass();
            msg.fromBytes(bytes);
        }
        return msg;
    }

    protected function onMessageReceived (e :MessageReceivedEvent) :void
    {
        if (e.senderId == PlatformerContext.myId || !(e.value is ByteArray)) {
            return;
        }
        var msg :GameMessage = getMessage(e.name, ByteArray(e.value));
        if (msg == null) {
            return;
        }
        var now :int = getTimer();
        if (msg is QueueMessage) {
            var queue :QueueMessage = msg as QueueMessage;
            while (queue.hasMessages()) {
                msg = queue.nextMessage(getMessage);
                msgCount++;
                if (msg is BaseGameMessage) {
                    msg.senderId = e.senderId;
                    dispatchEvent(msg as BaseGameMessage);
                } else {
                    dispatchEvent(new MessageReceivedEvent(msg.name, msg, e.senderId));
                }
            }
            /*
            _rec++;
            if (_rec == 10) {
                var now :int = getTimer();
                trace("got 10 messages in " + (now - _lastRec));
                _lastRec = now;
                _rec = 0;
            }
            */
        } else if (msg is BaseGameMessage) {
            msgCount++;
            msg.senderId = e.senderId;
            dispatchEvent(msg as BaseGameMessage);
        } else {
            msgCount++;
            dispatchEvent(new MessageReceivedEvent(e.name, msg, e.senderId));
        }
        recTicks += getTimer() - now;
    }

    protected function checkSend (msg :GameMessage) :void
    {
        if (_msgTypes.get(msg.name) == null) {
            throw new Error("can't send unrecognized message type '" + msg.name + "'");
        }
    }

    protected var _gameCtrl :GameControl;
    protected var _msgTypes :Map = Maps.newMapOf(String);
    protected var _lastRec :int;
    protected var _rec :int;
}
}
