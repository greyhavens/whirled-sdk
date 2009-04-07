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


    public var id :int;

    public var sprite :String;

    public var updateState :int;

    public var type :String;

    public var soundEvents :Array;

    public function Dynamic (insxml :XML = null)
    {
        if (insxml != null) {
            x = insxml.@x;
            y = insxml.@y;
            id = insxml.@id;
            type = insxml.@type;
            if (insxml.hasOwnProperty("@soundEvents")) {
                soundEvents = String(insxml.@soundEvents).split(",");
            }
        }
    }

    public function get x () :Number
    {
        return _x;
    }

    public function set x (x :Number) :void
    {
        if (_x != x) {
            _x = x;
            updateState |= U_POS;
        }
    }

    public function get y () :Number
    {
        return _y;
    }

    public function set y (y :Number) :void
    {
        if (_y != y) {
            _y = y;
            updateState |= U_POS;
        }
    }

    public function get dx () :Number
    {
        return _dx;
    }

    public function set dx (dx :Number) :void
    {
        if (_dx != dx) {
            _dx = dx;
            updateState |= U_VEL;
        }
    }

    public function get dy () :Number
    {
        return _dy;
    }

    public function set dy (dy :Number) :void
    {
        if (_dy != dy) {
            _dy = dy;
            updateState |= U_VEL;
        }
    }

    public function get inter () :int
    {
        return _inter;
    }

    public function set inter (inter :int) :void
    {
        if (_inter != inter) {
            _inter = inter;
            updateState |= U_INTER;
        }
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

    public function get enemyCount () :int
    {
        return isAlive() ? 1 : 0;
    }

    public function xmlInstance () :XML
    {
        var xml :XML = <dynamicdef/>;
        xml.@x = x;
        xml.@y = y;
        xml.@id = id;
        xml.@type = type;
        xml.@cname = ClassUtil.getClassName(this);
        if (soundEvents != null && soundEvents.length > 0) {
            xml.@soundEvents = soundEvents.join(",");
        }
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

    public function alwaysSpawn () :Boolean
    {
        return false;
    }

    public function spawnDist () :Number
    {
        return 0;
    }

    public function useCache () :Boolean
    {
        return false;
    }

    public function isAlive () :Boolean
    {
        return shouldSpawn();
    }

    public function amOwner () :Boolean
    {
        return PlatformerContext.myId == owner || ownerType() == OWN_ALL;
    }

    public function ownerType () :int
    {
        return OWN_PLAYER;
    }

    public function getNewOwner (closest :int) :int
    {
        return closest;
    }

    public function forceOwner () :Boolean
    {
        return false;
    }

    public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        bytes = (bytes != null ? bytes : new ByteArray());
        _inState = updateState;
        updateState = 0;
        bytes.writeInt(_inState);
        if ((_inState & U_POS) > 0) {
            bytes.writeFloat(_x);
            bytes.writeFloat(_y);
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
            _x = bytes.readFloat();
            _y = bytes.readFloat();
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
    protected var _x :Number = 0;
    protected var _y :Number = 0;
}
}
