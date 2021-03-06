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

import com.whirled.contrib.platformer.piece.Dynamic;

public class DynamicMessage extends BaseGameMessage
{
    public static const NAME :String = "dynamic";

    public var id :int;
    public var bytes :ByteArray;

    public static function wrap (d :Dynamic) :DynamicMessage
    {
        var msg :DynamicMessage = new DynamicMessage();
        msg.id = d.id;
        msg.bytes = d.toBytes();
        return msg;
    }

    override public function get name () :String
    {
        return NAME;
    }

    override public function toBytes (ba :ByteArray = null) :ByteArray
    {
        var ba :ByteArray = (ba != null ? ba : new ByteArray());
        ba.writeInt(id);
        ba.writeInt(bytes.length);
        ba.writeBytes(bytes);
        return ba;
    }

    override public function fromBytes (ba :ByteArray) :void
    {
        id = ba.readInt();
        bytes = new ByteArray();
        var length :int = ba.readInt();
        ba.readBytes(bytes, 0, length);
    }
}
}
