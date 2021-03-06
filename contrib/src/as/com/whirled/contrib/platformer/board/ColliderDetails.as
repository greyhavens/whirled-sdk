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

package com.whirled.contrib.platformer.board {

import com.whirled.contrib.platformer.piece.Actor;

public class ColliderDetails
{
    /** An array of LineData static colliders. */
    public var colliders :Array;
    public var lineCol :Array;

    /** An array of DynamicBounds dynamic colliders. */
    public var acolliders :Array;

    /** An array of LineData for collisions in acolliders. */
    public var alines :Array;

    /** The remaining time (in seconds) after the collision. */
    public var rdelta :Number;

    /** The x and y delta to reach the first collision. */
    public var fcdX :Number;
    public var fcdY :Number;

    /** The x and y delta from the original position. */
    public var oX :Number;
    public var oY :Number;

    /** The starting x and y position. */
    public var sX :Number;
    public var sY :Number;

    /** The starting dx and dy. */
    public var dx :Number;
    public var dy :Number;

    public function ColliderDetails (cols :Array, acols :Array, delta :Number)
    {
        colliders = cols;
        acolliders = acols;
        reset(delta);
    }

    public function initActor (a :Actor) :void
    {
        sX = a.x;
        sY = a.y;
        dx = a.dx;
        dy = a.dy;
    }

    public function isValid (a :Actor) :Boolean
    {
        return  a.x == sX && a.y == sY && a.dx == dx && a.dy == dy;
    }

    public function reset (delta :Number, a :Actor = null) :Boolean
    {
        rdelta = delta;
        alines = new Array();
        oX = 0;
        oY = 0;
        if (a == null || !isValid(a)) {
            lineCol = null;
            if (a != null) {
                initActor(a);
            }
            return true;
        }
        return false;
    }

    public function pushActor (db :DynamicBounds) :Boolean
    {
        if (acolliders == null) {
            acolliders = [ db ];
        } else {
            if (acolliders.indexOf(db) == -1) {
                acolliders.push(db);
            } else {
                return false;
            }
        }
        return true;
    }
}
}
