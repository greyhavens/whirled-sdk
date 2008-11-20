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

import com.whirled.contrib.platformer.board.LineData;

/**
 * A game actor that has orientation, acceleration and health.
 */
public class Actor extends Dynamic
{
    public static const ORIENT_LEFT :int = 0;
    public static const ORIENT_RIGHT :int = 1;
    public static const ORIENT_TURNING :int = 1 << 3;

    public static const ORIENT_SHOOT_F :int = 1 << 4;
    public static const ORIENT_SHOOT_U :int = 1 << 5;
    public static const ORIENT_SHOOT_D :int = 1 << 6;
    public static const ORIENT_SHOOT_MASK :int = ~(7 << 4);

    public static const HIT_FRONT :int = 1;
    public static const HIT_BACK :int = 1 << 2;
    public static const HIT_BIG :int = 1 << 5;

    public static const U_HEALTH :int = 1 << (DYN_COUNT + 1);
    public static const U_ORIENT :int = 1 << (DYN_COUNT + 2);
    public static const U_SHOOT :int = 1 << (DYN_COUNT + 3);
    public static const ACT_COUNT :int = DYN_COUNT + 3;

    public var width :Number = 0;
    public var height :Number = 0;

    public var accelX :Number = 0;
    public var accelY :Number = 0;

    public var wasHit :int;
    public var justShot :Boolean = false;
    public var events :Array = new Array();

    public var startHealth :Number;

    public var maxAttachable :Number = -1;
    public var maxWalkable :Number = -1;
    public var projCollider :Boolean = false;

    public function Actor (insxml :XML = null)
    {
        super(insxml);
    }

    public function toString () :String
    {
        var at :String = (attached != null) ? " attached" : "";
        return "actor: (" + x.toFixed(3) + ", " + y.toFixed(3) +
            ") d:(" + dx.toFixed(3) + ", " + dy.toFixed(3) + ")" + at;
    }

    public function doesHit (x :Number, y :Number) :Boolean
    {
        return true;
    }

    public function orientBody (body :int) :void
    {
        orient = (orient & ~ORIENT_RIGHT) | body;
    }

    public function orientShoot (shoot :int) :void
    {
        orient = (orient & ORIENT_SHOOT_MASK) | shoot;
    }

    public function get attached () :LineData
    {
        return _attached;
    }

    public function get attachedId () :int
    {
        return _attachedId;
    }

    public function get health () :Number
    {
        return _health;
    }

    public function set health (health :Number) :void
    {
        _health = health;
        updateState |= U_HEALTH;
    }

    public function get orient () :int
    {
        return _orient;
    }

    public function set orient (orient :int) :void
    {
        if (orient != _orient) {
            _orient = orient;
            updateState |= U_ORIENT;
        }
    }

    public function get shooting () :Boolean
    {
        return _shooting;
    }

    public function set shooting (shooting :Boolean) :void
    {
        _shooting = shooting;
        updateState |= U_SHOOT;
    }

    public function setAttached (ld :LineData, id :int = -1) :void
    {
        _attached = ld;
        _attachedId = id;
    }

    override public function getBounds () :Rect
    {
        if (_bounds == null) {
            _bounds = new Rect(x, y, width, height);
        }
        _bounds.x = x;
        _bounds.y = y;
        return _bounds;
    }

    override public function shouldSpawn () :Boolean
    {
        return health > 0;
    }

    override public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        bytes = super.toBytes(bytes);
        if ((_inState & U_HEALTH) > 0) {
            bytes.writeFloat(_health);
            //trace("toBytes health (" + health + ")");
        }
        if ((_inState & U_ORIENT) > 0) {
            bytes.writeInt(_orient);
        }
        if ((_inState & U_SHOOT) > 0) {
            bytes.writeBoolean(_shooting);
        }
        return bytes;
    }

    override public function fromBytes (bytes :ByteArray) :void
    {
        super.fromBytes(bytes);
        if ((_inState & U_HEALTH) > 0) {
            _health = bytes.readFloat();
            //trace("fromBytes health (" + health + ")");
        }
        if ((_inState & U_ORIENT) > 0) {
            _orient = bytes.readInt();
        }
        if ((_inState & U_SHOOT) > 0) {
            _shooting = bytes.readBoolean();
        }
    }

    protected var _bounds :Rect;
    protected var _attached :LineData;
    protected var _attachedId :int;
    protected var _health :Number;
    protected var _orient :int = ORIENT_RIGHT | ORIENT_SHOOT_F;
    protected var _shooting :Boolean = false;
}
}
