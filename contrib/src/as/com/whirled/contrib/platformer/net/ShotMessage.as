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

public class ShotMessage extends BaseGameMessage
{
    public static const NAME :String = "shot";

    public static const HIT :int = 1;
    public static const DAMAGE :int = 2;
    public static const RECORD :int = 3;

    public var state :int;
    public var id :int;
    public var damage :Number;
    public var inter :int;
    public var owner :int;

    public static function shotHit (id :int, damage :Number, inter :int, owner :int) :ShotMessage
    {
        return create(HIT, id, damage, inter, owner);
    }

    public static function shotDamage (id :int, damage :Number, inter :int, owner :int) :ShotMessage
    {
        return create(DAMAGE, id, damage, inter, owner);
    }

    public static function recordShot (id :int, owner :int) :ShotMessage
    {
        return create(RECORD, id, 0, 0, owner);
    }

    public static function create (
        state :int, id :int, damage :Number, inter :int, owner :int) :ShotMessage
    {
        var msg :ShotMessage = new ShotMessage();
        msg.state = state;
        msg.id = id;
        msg.damage = damage;
        msg.inter = inter;
        msg.owner = owner;
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
        ba.writeByte(inter);
        ba.writeInt(id);
        ba.writeInt(owner);
        ba.writeFloat(damage);
        return ba;
    }

    override public function fromBytes (ba :ByteArray) :void
    {
        state = ba.readByte();
        inter = ba.readByte();
        id = ba.readInt();
        owner = ba.readInt();
        damage = ba.readFloat();
    }
}
}
