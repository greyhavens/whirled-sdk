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

import flash.utils.ByteArray;

import com.threerings.util.HashMap;

public class QueueMessage extends BaseGameMessage
{
    public static const NAME :String = "queue";

    public var msgs :Array;
    public var bytes :ByteArray;

    public function addMessage (msg :GameMessage) :void
    {
        if (msgs == null) {
            msgs = new Array();
        }
        msgs.push(msg);
    }

    override public function get name () :String
    {
        return NAME;
    }

    override public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        bytes = (bytes != null ? bytes : new ByteArray());
        if (msgs != null) {
            for each (var msg :GameMessage in msgs) {
                bytes.writeUTF(msg.name);
                msg.toBytes(bytes);
            }
        }
        return bytes;
    }

    override public function fromBytes (bytes :ByteArray) :void
    {
        this.bytes = bytes;
    }

    public function hasMessages () :Boolean
    {
        return bytes != null && bytes.bytesAvailable > 0;
    }

    public function nextMessage (getMessage :Function) :GameMessage
    {
        return getMessage(bytes.readUTF(), bytes);
    }
}
}
