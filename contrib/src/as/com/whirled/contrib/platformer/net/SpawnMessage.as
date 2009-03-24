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

public class SpawnMessage extends BaseGameMessage
{
    public static const NAME :String = "spawn";

    public static const PLAYER :int = 1;
    public static const DYNAMIC :int = 2;
    public static const REMOVE :int = 3;
    public static const SPAWN :int = 4;
    public static const OWNER :int = 5;
    public static const REQUEST_OWNER :int = 6;

    public var state :int;
    public var id :int;
    public var idx :int;
    public var x :Number;
    public var y :Number;

    public static function spawnPlayer (id :int, idx :int, x :Number, y :Number) :SpawnMessage
    {
        var msg :SpawnMessage = create(PLAYER, id, idx, x, y);
        return msg;
    }

    public static function spawnDynamic (id :int, owner :int) :SpawnMessage
    {
        return create(DYNAMIC, id, owner);
    }

    public static function removeDynamic (id :int, store :Boolean) :SpawnMessage
    {
        return create(REMOVE, id, store ? 1 : 0);
    }

    public static function spawnIndex (idx :int, x :Number = 0, y :Number = 0) :SpawnMessage
    {
        return create(SPAWN, 0, idx, x, y);
    }

    public static function changeOwner (id :int, owner :int) :SpawnMessage
    {
        return create(OWNER, id, owner);
    }

    public static function requestOwnerChange (id :int, owner :int) :SpawnMessage
    {
        return create(REQUEST_OWNER, id, owner);
    }

    public static function create (
            state :int, id :int, idx :int = 0, x :Number = 0, y :Number = 0) :SpawnMessage
    {
        var msg :SpawnMessage = new SpawnMessage();
        msg.state = state;
        msg.id = id;
        msg.idx = idx;
        msg.x = x;
        msg.y = y;
        return msg;
    }

    override public function get name () :String
    {
        return NAME;
    }

    override public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        bytes = (bytes != null ? bytes : new ByteArray());
        bytes.writeByte(state);
        bytes.writeInt(id);
        bytes.writeInt(idx);
        if (state == PLAYER || (state == SPAWN && idx == 0)) {
            bytes.writeFloat(x);
            bytes.writeFloat(y);
        }
        return bytes;
    }

    override public function fromBytes (bytes :ByteArray) :void
    {
        state = bytes.readByte();
        id = bytes.readInt();
        idx = bytes.readInt();
        if (state == PLAYER || (state == SPAWN && idx == 0)) {
            x = bytes.readFloat();
            y = bytes.readFloat();
        }
    }
}
}
