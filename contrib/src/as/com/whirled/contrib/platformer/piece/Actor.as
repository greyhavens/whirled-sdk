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
import com.whirled.contrib.platformer.game.Collision;

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
    public static const ORIENT_SHOOT_B :int = 1 << 7;
    public static const ORIENT_SHOOT_MASK :int = ~(15 << 4);

    public static const HIT_FRONT :int = 1;
    public static const HIT_BACK :int = 1 << 2;
    public static const HIT_BIG :int = 1 << 5;

    public static const U_HEALTH :int = 1 << (DYN_COUNT + 1);
    public static const U_ORIENT :int = 1 << (DYN_COUNT + 2);
    public static const U_SHOOT :int = 1 << (DYN_COUNT + 3);
    public static const U_HIT :int = 1 << (DYN_COUNT + 4);
    public static const U_ACCEL :int = 1 << (DYN_COUNT + 5);
    public static const U_ATTACH :int = 1 << (DYN_COUNT + 6);
    public static const U_UPGRADE :int = 1 << (DYN_COUNT + 7);
    public static const ACT_COUNT :int = DYN_COUNT + 7;

    public var events :Array = new Array();

    public var maxAttachable :Number = -1;
    public var maxWalkable :Number = -1;
    public var projCollider :Boolean = false;

    public function Actor (insxml :XML = null)
    {
        super(insxml);
        if (insxml != null) {
            disabled = insxml.@disabled == "true";
        }
    }

    public function toString () :String
    {
        var at :String = (attached != null) ? " attached" : "";
        return "actor: (" + x.toFixed(3) + ", " + y.toFixed(3) +
            ") d:(" + dx.toFixed(3) + ", " + dy.toFixed(3) + ")" + at;
    }

    public function doesHit (x :Number, y :Number, source :Object) :Collision
    {
        throw new Error("doesHit() in Actor is abstract!");
    }

    public function orientBody (body :int) :void
    {
        orient = (orient & ~ORIENT_RIGHT) | body;
    }

    public function orientShoot (shoot :int) :void
    {
        orient = (orient & ORIENT_SHOOT_MASK) | shoot;
    }

    public function isOrientShootDown () :Boolean
    {
        return (orient & (ORIENT_SHOOT_D | ORIENT_SHOOT_F)) == ORIENT_SHOOT_D;
    }

    public function isOrientShootUp () :Boolean
    {
        return (orient & (ORIENT_SHOOT_U | ORIENT_SHOOT_F)) == ORIENT_SHOOT_U;
    }

    public function get width () :Number
    {
        return _width;
    }

    public function set width (width :Number) :void
    {
        _width = width;
    }

    public function get height () :Number
    {
        return _height;
    }

    public function set height (height :Number) :void
    {
        _height = height;
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

    public function get startHealth () :Number
    {
        return _startHealth;
    }

    public function set startHealth (startHealth :Number) :void
    {
        _startHealth = startHealth;
        updateState |= U_UPGRADE;
    }

    public function get disabled () :Boolean
    {
        return _disabled;
    }

    public function set disabled (disabled :Boolean) :void
    {
        if (disabled != _disabled) {
            _disabled = disabled;
            updateState |= U_INTER;
        }
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

    public function get justShot () :Boolean
    {
        return _justShot;
    }

    public function set justShot (justShot :Boolean) :void
    {
        if (_justShot != justShot) {
            _justShot = justShot;
            updateState |= U_SHOOT;
        }
    }

    public function get wasHit () :int
    {
        return _wasHit;
    }

    public function set wasHit (wasHit :int) :void
    {
        _wasHit = wasHit;
        updateState |= U_HIT;
    }

    public function get killer () :int
    {
        return _killer;
    }

    public function set killer (killer :int) :void
    {
        _killer = killer;
        updateState |= U_HIT;
    }

    public function get accelX () :Number
    {
        return _accelX;
    }

    public function set accelX (accelX :Number) :void
    {
        if (_accelX != accelX) {
            _accelX = accelX;
            updateState |= U_ACCEL;
        }
    }

    public function get accelY () :Number
    {
        return _accelY;
    }

    public function set accelY (accelY :Number) :void
    {
        if (_accelY != accelY) {
            _accelY = accelY;
            updateState |= U_ACCEL;
        }
    }

    public function setAttached (ld :LineData, id :int = -1) :void
    {
        _attached = ld;
        if (_attachedId != id) {
            updateState |= U_ATTACH;
            _attachedId = id;
        }
    }

    public function applyForce (fx :Number, fy :Number) :void
    {
        dx += fx;
        dy += fy;
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
        return health > 0 && !disabled;
    }

    override public function isAlive () :Boolean
    {
        return health > 0;
    }

    override public function xmlInstance () :XML
    {
        var xml :XML = super.xmlInstance();
        xml.@disabled = disabled;
        return xml;
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
            bytes.writeBoolean(_justShot);
        }
        if ((_inState & U_HIT) > 0) {
            bytes.writeByte(_wasHit);
            bytes.writeInt(_killer);
        }
        if ((_inState & U_ACCEL) > 0) {
            bytes.writeFloat(_accelX);
            bytes.writeFloat(_accelY);
        }
        if ((_inState & U_ATTACH) > 0) {
            bytes.writeInt(_attachedId);
        }
        if ((_inState & U_UPGRADE) > 0) {
            bytes.writeFloat(_startHealth);
        }
        if ((_inState & U_INTER) > 0) {
            bytes.writeBoolean(_disabled);
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
            _justShot = bytes.readBoolean();
        }
        if ((_inState & U_HIT) > 0) {
            _wasHit = bytes.readByte();
            _killer = bytes.readInt();
        }
        if ((_inState & U_ACCEL) > 0) {
            _accelX = bytes.readFloat();
            _accelY = bytes.readFloat();
        }
        if ((_inState & U_ATTACH) > 0) {
            _attachedId = bytes.readInt();
        }
        if ((_inState & U_UPGRADE) > 0) {
            _startHealth = bytes.readFloat();
        }
        if ((_inState & U_INTER) > 0) {
            _disabled = bytes.readBoolean();
        }
    }

    protected var _bounds :Rect;
    protected var _attached :LineData;
    protected var _attachedId :int = -1;
    protected var _health :Number;
    protected var _startHealth :Number;
    protected var _orient :int = ORIENT_RIGHT | ORIENT_SHOOT_F;
    protected var _shooting :Boolean = false;
    protected var _justShot :Boolean = false;
    protected var _wasHit :int;
    protected var _accelX :Number = 0;
    protected var _accelY :Number = 0;
    protected var _height :Number = 0;
    protected var _width :Number = 0;
    protected var _killer :int;
    protected var _disabled :Boolean;
}
}
