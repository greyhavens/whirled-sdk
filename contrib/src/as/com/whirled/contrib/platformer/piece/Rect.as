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

public class Rect
{
    public var x :Number;
    public var y :Number;
    public var height :Number;
    public var width :Number;

    public function Rect (x :Number = 0, y :Number = 0, width :Number = 0, height :Number = 0)
    {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
    }

    public function get centerX () :Number
    {
        return x + width/2;
    }

    public function get centerY () :Number
    {
        return y + height/2;
    }

    public function clone () :Rect
    {
        return new Rect(x, y, width, height);
    }

    public function includePoint (px :Number, py :Number) :void
    {
        if (px < x) {
            width += x - px;
            x = px;
        } else if (px > x + width) {
            width = px - x;
        }
        if (py < y) {
            height += y - py;
            y = py;
        } else if (py > y + height) {
            height = py - y;
        }
    }

    public function grow (value :Number) :void
    {
        x -= value;
        y -= value;
        width += value*2;
        height += value*2;
    }

    public function overlaps (other :Rect, grow :Number = 0) :Boolean
    {
        return x - grow <= other.x + other.width + grow && x + width + grow >= other.x - grow &&
                y - grow <= other.y + other.height + grow && y + height + grow >= other.y - grow;
    }

    public function contains (other :Rect) :Boolean
    {
        return x <= other.x && x + width >= other.x + other.width &&
            y <= other.y && y + height >= other.y + other.height;
    }

    public function toString () :String
    {
        return "rect: (" + x.toFixed(3) + ", " + y.toFixed(3) + ", " +
            width.toFixed(3) + ", " + height.toFixed(3) + ")";
    }
}
}
