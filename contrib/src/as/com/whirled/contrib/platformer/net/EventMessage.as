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

public class EventMessage extends BaseGameMessage
{
    public static const NAME :String = "event";

    public static const TRIGGER :int = 1;

    public var state :int;
    public var id :int;

    public static function create (state :int, id :int) :EventMessage
    {
        var msg :EventMessage = new EventMessage();
        msg.state = state;
        msg.id = id;
        return msg;
    }

    override public function get name () :String
    {
        return NAME;
    }

    override public function toBytes (ba :ByteArray = null) :ByteArray
    {
        var ba :ByteArray = (ba != null ? ba : new ByteArray());
        ba.writeByte(state);
        ba.writeInt(id);
        return ba;
    }

    override public function fromBytes (ba :ByteArray) :void
    {
        state = ba.readByte();
        id = ba.readInt();
    }
}
}
