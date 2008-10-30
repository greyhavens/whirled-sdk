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

import com.threerings.util.HashMap;

import com.whirled.game.GameControl;
import com.whirled.net.MessageReceivedEvent;

public class MessageManager extends EventDispatcher
{
    public function MessageManager (gameCtrl :GameControl)
    {
        _gameCtrl = gameCtrl;
        _gameCtrl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, onMessageReceived);
    }

    public function addMessageType (messageClass :Class) :void
    {
        if (_msgTypes.put(messageClass.NAME, messageClass) !== undefined) {
            throw new Error("can't add duplicate '" + messageClass.NAME + "' message type");
        }
    }

    public function sendMessage (msg :GameMessage) :void
    {
        if (_msgTypes.get(msg.name) == null) {
            throw new Error("can't send unrecognized message type '" + msg.name + "'");
        }

        _gameCtrl.net.sendMessage(msg.name, msg.toBytes());
    }

    protected function onMessageReceived (e :MessageReceivedEvent) :void
    {
        var msgClass :Class = _msgTypes.get(e.name);
        if (msgClass != null) {
            var msg :GameMessage = new msgClass();
            msg.fromBytes(ByteArray(e.value));
            dispatchEvent(new MessageReceivedEvent(e.name, msg, e.senderId));
        }
    }

    protected var _gameCtrl :GameControl;
    protected var _msgTypes :HashMap = new HashMap();
}
}
