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

package com.whirled.contrib.platformer.util {

/**
 * Some useful math functions.
 */
public class Maths
{
    /**
     * Returns the 1 if val > 0, -1 if val < 0 and 0 if val == 0.
     */
    public static function sign0 (val :Number) :Number
    {
        return (val == 0) ? 0 : (val > 0) ? 1 : -1;
    }

    /**
     * Returns the value limited to the range -mag <= val <= mag.
     */
    public static function limit (val :Number, mag :Number) :Number
    {
        return (Math.abs(val) > mag) ? sign0(val) * mag : val;
    }

    /**
     * Returns the squared distance between two points.
     */
    public static function getDist2 (x1 :Number, y1 :Number, x2 :Number, y2 :Number) :Number
    {
        return (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2);
    }

    /**
     * Compares two numbers to be within minimal difference.
     */
    public static function equalsy (a :Number, b :Number) :Boolean
    {
        return Math.abs(a - b) < EPSILON;
    }

    protected static const EPSILON :Number = 0.0001;
}
}
