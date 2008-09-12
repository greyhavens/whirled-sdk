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
    public static const HIT_BACK :int = 2;

    public var width :Number = 0;
    public var height :Number = 0;
    public var orient :int = ORIENT_RIGHT | ORIENT_SHOOT_F;

    public var accelX :Number = 0;
    public var accelY :Number = 0;

    public var shooting :Boolean = false;
    public var wasHit :int;
    public var justShot :Boolean = false;
    public var events :Array = new Array();

    public var attached :LineData;
    public var health :Number;
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

    override public function getBounds () :Rect
    {
        if (_bounds == null) {
            _bounds = new Rect(x, y, width, height);
        }
        _bounds.x = x;
        _bounds.y = y;
        return _bounds;
    }

    protected var _bounds :Rect;
}
}
