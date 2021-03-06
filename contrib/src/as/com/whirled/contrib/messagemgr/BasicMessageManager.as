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

package com.whirled.contrib.messagemgr {

import com.threerings.util.Log;
import com.threerings.util.Map;
import com.threerings.util.Maps;

import flash.events.EventDispatcher;
import flash.utils.ByteArray;

public class BasicMessageManager extends EventDispatcher
    implements MessageManager
{
    public function addMessageType (messageClass :Class) :void
    {
        var msg :Message = new messageClass();
        if (_messageTypes.put(msg.name, messageClass) !== undefined) {
            throw new Error("Message type '" + msg.name + "' already registered");
        }
    }

    public function deserializeMessage (name :String, val :Object) :Message
    {
        var messageClass :Class = _messageTypes.get(name) as Class;
        if (null == messageClass) {
            //log.info("Discarding incoming '" + name + "' message (message type not registered)");
            return null;
        }

        var msg :Message = new messageClass();
        try {
            var bytes :ByteArray = ByteArray(val);
            bytes.position = 0;
            msg.fromBytes(bytes);
        } catch (e :Error) {
            log.warning("Failed to deserialize incoming '" + name + "' message", e);
            return null;
        }

        return msg;
    }

    protected var _messageTypes :Map = Maps.newMapOf(String);

    protected const log :Log = Log.getLog(this);
}

}
