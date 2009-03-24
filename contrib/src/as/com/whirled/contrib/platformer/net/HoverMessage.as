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

import com.whirled.contrib.platformer.net.BaseGameMessage;

public class HoverMessage extends BaseGameMessage
{
    public static const NAME :String = "hover";

    public static const HOVER :int = 1;
    public static const UNHOVER :int = 2;

    public var state :int;
    public var id :int;

    public static function create (state :int, id :int) :HoverMessage
    {
        var msg :HoverMessage = new HoverMessage();
        msg.state = state;
        msg.id = id;
        return msg;
    }

    override public function get name () :String
    {
        return NAME;
    }

    override public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        bytes = (bytes != null ? bytes :new ByteArray());
        bytes.writeByte(state);
        bytes.writeInt(id);
        return bytes;
    }

    override public function fromBytes (bytes :ByteArray) :void
    {
        state = bytes.readByte();
        id = bytes.readInt();
    }
}
}

