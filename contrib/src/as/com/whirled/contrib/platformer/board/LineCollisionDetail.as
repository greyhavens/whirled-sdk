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

public class LineCollisionDetail
{
    public static const MISS :int = -100;
    public static const IGNORE :int = -1;
    public static const HIT :int = 1;
    public static const CONNECTED :int = 2;
    public static const IGNORE_CONNECTED :int = 3;
    public static const IGNORE_UNCONNECTED :int = 4;

    public var sX :Number;
    public var sY :Number;
    public var cdX :Number;
    public var cdY :Number;
    public var lines :Array;
    public var delta :Number;

    public function LineCollisionDetail (
            sX :Number, sY :Number, cdX :Number, cdY :Number, delta :Number, nlines :int)
    {
        this.sX = sX;
        this.sY = sY;
        this.cdX = cdX;
        this.cdY = cdY;
        lines = new Array(nlines);
    }

    public function clone (
            sX :Number, sY :Number, cdX :Number, cdY :Number, delta :Number) :LineCollisionDetail
    {
        var lcd :LineCollisionDetail =
                new LineCollisionDetail(sX, sY, cdX, cdY, delta, lines.length);
        for (var ii :int = 0; ii < lines.length; ii++) {
            lcd.lines[ii] = lines[ii];
        }
        return lcd;
    }

    public function isValid (sX :Number, sY :Number, cdX :Number, cdY :Number) :Boolean
    {
        return this.sX == sX && this.sY == sY && this.cdX == cdX && this.cdY == cdY;
    }
}
}
