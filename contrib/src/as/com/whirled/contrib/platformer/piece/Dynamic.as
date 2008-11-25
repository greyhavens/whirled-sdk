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

package com.whirled.contrib.platformer.piece {

import flash.utils.ByteArray;

import com.threerings.util.ClassUtil;
import com.threerings.util.Hashable;

import com.whirled.contrib.platformer.PlatformerContext;

/**
 * Base class for any object that can move in the world.
 */
public class Dynamic
    implements Hashable
{
    public static const GLOBAL :int = 0;
    public static const PLAYER :int = 1;
    public static const ENEMY :int = 2;
    public static const DEAD :int = 3;
    public static const SPAWN :int = 4;

    public static const OWN_PLAYER :int = 1;
    public static const OWN_SERVER :int = 2;
    public static const OWN_ALL :int = 3;

    public static const U_POS :int = 1 << 0;
    public static const U_VEL :int = 1 << 1;
    public static const U_INTER :int = 1 << 2;
    public static const DYN_COUNT :int = 2;

    public var x :Number = 0;
    public var y :Number = 0;

    public var id :int;

    public var sprite :String;

    public var updateState :int;

    public function Dynamic (insxml :XML = null)
    {
        if (insxml != null) {
            x = insxml.@x;
            y = insxml.@y;
            id = insxml.@id;
        }
    }

    public function get dx () :Number
    {
        return _dx;
    }

    public function set dx (dx :Number) :void
    {
        _dx = dx;
        updateState |= U_VEL;
    }

    public function get dy () :Number
    {
        return _dy;
    }

    public function set dy (dy :Number) :void
    {
        _dy = dy;
        updateState |= U_VEL;
    }

    public function get inter () :int
    {
        return _inter;
    }

    public function set inter (inter :int) :void
    {
        _inter = inter;
        updateState |= U_INTER;
    }

    public function get owner () :int
    {
        return _owner;
    }

    public function set owner (owner :int) :void
    {
        _owner = owner;
        updateState = 0;
    }

    public function xmlInstance () :XML
    {
        var xml :XML = <dynamicdef/>;
        xml.@x = x;
        xml.@y = y;
        xml.@id = id;
        xml.@cname = ClassUtil.getClassName(this);
        return xml;
    }

    public function hashCode () :int
    {
        return id;
    }

    public function equals (other :Object) :Boolean
    {
        return (other is Dynamic && (other as Dynamic).id == id);
    }

    public function getBounds () :Rect
    {
        return new Rect(x, y);
    }

    public function shouldSpawn () :Boolean
    {
        return true;
    }

    public function isAlive () :Boolean
    {
        return shouldSpawn();
    }

    public function amOwner () :Boolean
    {
        return PlatformerContext.gctrl.game.getMyId() == owner;
    }

    public function ownerType () :int
    {
        return OWN_PLAYER;
    }

    public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        bytes = (bytes != null ? bytes : new ByteArray());
        _inState = updateState;
        updateState = 0;
        bytes.writeInt(_inState);
        if ((_inState & U_POS) > 0) {
            bytes.writeFloat(x);
            bytes.writeFloat(y);
            //trace("toBytes pos (" + x + ", " + y + ")");
        }
        if ((_inState & U_VEL) > 0) {
            bytes.writeFloat(_dx);
            bytes.writeFloat(_dy);
        }
        if ((_inState & U_INTER) > 0) {
            bytes.writeByte(_inter);
        }
        return bytes;
    }

    public function fromBytes (bytes :ByteArray) :void
    {
        _inState = bytes.readInt();
        if ((_inState & U_POS) > 0) {
            x = bytes.readFloat();
            y = bytes.readFloat();
            //trace("fromBytes pos (" + x + ", " + y + ")");
        }
        if ((_inState & U_VEL) > 0) {
            _dx = bytes.readFloat();
            _dy = bytes.readFloat();
        }
        if ((_inState & U_INTER) > 0) {
            _inter = bytes.readByte();
        }
    }

    protected var _inState :int;
    protected var _dx :Number = 0;
    protected var _dy :Number = 0;
    protected var _inter :int;
    protected var _owner :int;
}
}
