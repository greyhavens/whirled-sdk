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

/**
 * Constants for BoundedPiece.
 */
public class BoundData
{
    public static const MASK :int = 255;
    public static const NONE :int = 0;
    public static const ALL :int = 1;
    public static const OUTER :int = 2;
    public static const INNER :int = 3;
    public static const REPULSE :int = 4;
    public static const ACCEL :int = 5;

    public static const S_MASK :int = 255 << 8;
    public static const S_NONE :int = 0 << 8;
    public static const S_ALL :int = 1 << 8;
    public static const S_OUTER :int = 2 << 8;
    public static const S_INNER :int = 3 << 8;

    public static const COLOR :Array = [
        0xAAAAAA, 0xFF0000, 0x00FF00, 0x0000FF, 0xFFFF00, 0xFF00FF
    ];

    public static function doesBound (type :int, projectile :Boolean = false) :Boolean
    {
        if (projectile) {
            type = getShotBound(type);
            return type != S_NONE;
        }
        type = getNormalBound(type);
        return (type != NONE && type != ACCEL);
    }

    public static function getNormalBound (type :int) :int
    {
        return type & MASK;
    }

    public static function getShotBound (type :int) :int
    {
        return type & S_MASK;
    }

    public static function getColor (type :int) :int
    {
        return COLOR[getNormalBound(type)];
    }

    public static function blockOuter (type :int, projectile :Boolean = false) :Boolean
    {
        if (projectile) {
            type = getShotBound(type);
            return type == S_OUTER || type == S_ALL;
        }
        type = getNormalBound(type)
        return (type == OUTER || type == ALL || type == REPULSE);
    }

    public static function blockInner (type :int, projectile :Boolean = false) :Boolean
    {
        if (projectile) {
            type = getShotBound(type);
            return type == S_INNER || type == S_ALL;
        }
        type = getNormalBound(type);
        return (type == INNER || type == ALL || type == REPULSE);
    }

    public static function swapBounds (type :int) :int
    {
        var normal :int = type & MASK;
        if (normal == OUTER) {
            normal = INNER;
        } else if (normal == INNER) {
            normal = OUTER;
        }
        var projectile :int = type & S_MASK;
        if (projectile == S_OUTER) {
            projectile = S_INNER;
        } else if (projectile == S_INNER) {
            projectile = S_OUTER;
        }
        return normal | projectile;
    }
}
}
