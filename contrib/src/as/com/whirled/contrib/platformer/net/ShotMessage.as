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

import com.whirled.contrib.platformer.piece.Shot;

public class ShotMessage
    implements GameMessage
{
    public static const NAME :String = "shot";

    public static const HIT :int = 1;
    public static const DAMAGE :int = 2;

    public var type :int;
    public var id :int;
    public var damage :Number;
    public var inter :int;
    public var bytes :ByteArray;

    public static function shotHit (id :int, damage :Number, inter :int) :ShotMessage
    {
        var msg :ShotMessage = new ShotMessage();
        msg.type = HIT;
        msg.id = id;
        msg.damage = damage;
        msg.inter = inter;
        return msg;
    }

    public static function shotDamage (id :int, damage :Number, inter :int) :ShotMessage
    {
        var msg :ShotMessage = new ShotMessage();
        msg.type = DAMAGE;
        msg.id = id;
        msg.damage = damage;
        msg.inter = inter;
        return msg;
    }

    public function get name () :String
    {
        return NAME;
    }

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        var ba :ByteArray = (ba != null ? ba : new ByteArray());
        ba.writeByte(type);
        ba.writeInt(id);
        ba.writeFloat(damage);
        ba.writeByte(inter);
        return ba;
    }

    public function fromBytes (ba :ByteArray) :void
    {
        type = ba.readByte();
        id = ba.readInt();
        damage = ba.readFloat();
        inter = ba.readByte();
    }
}
}
