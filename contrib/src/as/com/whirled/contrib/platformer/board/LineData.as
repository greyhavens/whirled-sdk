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

import flash.geom.Point;
import flash.utils.Dictionary;
import com.whirled.contrib.platformer.piece.BoundData;

/**
 * Information aboult a line segment in 2-dimensional space that allows some quick efficient
 * operations and comparisons.
 */
public class LineData
{
    public const EPSILON :Number = 0.000000001;
    public var x1 :Number;
    public var x2 :Number;
    public var y1 :Number;
    public var y2 :Number;
    public var nx :Number;
    public var ny :Number;
    public var ix :Number;
    public var iy :Number;
    public var D :Number;
    public var mag :Number;
    public var type :int;

    public static function createFromPoints(p1 :Point, p2 :Point, type :int) :LineData
    {
        return new LineData(p1.x, p1.y, p2.x, p2.y, type);
    }

    public static function doPolygonsCollide (lines :Array, olines :Array) :Boolean
    {
        for each (var ld :LineData in lines) {
            if (ld.polyIntersecting(olines)) {
                return true;
            }
        }
        return false;
    }

    public function LineData (x1 :Number, y1 :Number, x2 :Number, y2: Number, type :int)
    {
        this.x1 = x1;
        this.x2 = x2;
        this.y1 = y1;
        this.y2 = y2;
        this.type = type;
        init();
    }

    public function init () :void
    {
        ix = x2 - x1;
        iy = y2 - y1;
        mag = Math.sqrt(ix * ix + iy * iy);
        ix /= mag;
        iy /= mag;
        nx = -iy;
        ny = ix;
        D = - x1 * nx - y1 * ny;
    }

    /**
     * Translates the line.  If an other line is supplied, the other line is moved to this lines
     * translated position (and this line is remained unchanged).  The other line should have the
     * same angle and magnitude.
     */
    public function translate (x :Number, y :Number, other :LineData = null) :void
    {
        if (other == null) {
            other = this;
        }
        other.x1 = x1 + x;
        other.x2 = x2 + x;
        other.y1 = y1 + y;
        other.y2 = y2 + y;
        other.D = -other.x1 * nx - other.y1 * ny;
    }

    /**
     * Updates a lines coordinates.  The supplied coordinates should have the same angle as the
     * old line values, but the magnitude can change.
     */
    public function update (
            x1 :Number, y1 :Number, x2 :Number, y2 :Number, reset :Boolean = false) :void
    {
        if (this.x1 != x1 || this.y1 != y1 || this.x2 != x2 || this.y2 != y2) {
            mag = Math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
            this.x1 = x1;
            this.y1 = y1;
            this.x2 = x2;
            this.y2 = y2;
            if (reset) {
                init();
            } else {
                D = -x1 * nx - y1 * ny;
            }
        }
    }

    public function clone () :LineData
    {
        return new LineData(x1, y1, x2, y2, type);
    }

    /**
     * Checks if this line is connected to the supplied line.  If convex is true, then the two
     * lines must be connected and form a convex shape that will prevent collision from outside
     * the lines.
     *
     * returns: An array of 2 values containing the distance of the non-connected points to
     * the other line.
     */
    public function isConnected (line :LineData, convex :Boolean = true) :Array
    {
        if (_connected == null) {
            _connected = new Dictionary();
        }
        if (convex && _connected[line] !== undefined) {
            return _connected[line];
        }
        if (line == null || !BoundData.doesBound(type) || !BoundData.doesBound(line.type)) {
            if (convex) {
                _connected[line] = null;
            }
            return null;
        }

        var mX :Number;
        var mY :Number;
        var oX :Number;
        var oY :Number;

        var ret :Array = new Array();

        if (x1 == line.x1 && y1 == line.y1) {
            mX = x2;
            mY = y2;
            oX = line.x2;
            oY = line.y2;
        } else if (x1 == line.x2 && y1 == line.y2) {
            mX = x2;
            mY = y2;
            oX = line.x1;
            oY = line.y1;
        } else if (x2 == line.x1 && y2 == line.y1) {
            mX = x1;
            mY = y1;
            oX = line.x2;
            oY = line.y2;
        } else if (x2 == line.x2 && y2 == line.y2) {
            mX = x1;
            mY = y1;
            oX = line.x1;
            oY = line.y1;
        } else {
            if (convex) {
                _connected[line] = null;
            }
            return null;
        }
        ret.push(getDist(oX, oY));
        ret.push(line.getDist(mX, mY));

        if (convex && ((!BoundData.blockInner(type) && ret[0] >= 0) ||
                (!BoundData.blockOuter(type) && ret[0] <= 0) ||
                (!BoundData.blockInner(line.type) && ret[1] >= 0) ||
                (!BoundData.blockOuter(line.type) && ret[1] <= 0))) {
            if (convex) {
                _connected[line] = null;
            }
            return null;
        }
        if (convex) {
            _connected[line] = ret;
        }
        return ret;
    }

    /**
     * Returns the dot product of this line and the supplied point.
     */
    public function dot (x :Number, y :Number) :Number
    {
        return x * ix + y * iy;
    }

    /**
     * Returns the dot product of this line and the supplied point.
     */
    public function relDot (x :Number, y :Number) :Number
    {
        return (x - x1) * ix + (y - y1) * iy;
    }

    /**
     * Returns the dot product of the normal and the supplied point.
     */
    public function normalDot (x :Number, y :Number) :Number
    {
        return x * nx + y * ny;
    }

    /**
     * Returns the distance from the plane of this line and the supplied point.  The distance is
     * positive if the point is outside the line, negative if the point is inside the line or zero
     * if the point is on the line.
     */
    public function getDist (x :Number, y :Number) :Number
    {
        return x * nx + y * ny + D;
    }

    /**
     * Returns the square of the distance between this line segment and the supplied point.
     */
    public function getSegmentDist2 (x :Number, y :Number) :Number
    {
        //var r :Number = relDot(x, y);
        var r :Number = (x - x1) * ix + (y - y1) * iy;
        if (r < 0) {
            return (x1 - x) * (x1 - x) + (y1 - y) * (y1 - y);
        } else if (r > mag) {
            return (x2 - x) * (x2 - x) + (y2 - y) * (y2 - y);
        }
        //r = getDist(x, y);
        r = x * nx + y * ny + D;
        return r * r;
    }

    /**
     * Returns the distance on the line to the near intersection between this line and the
     * supplied circle.
     */
    public function getCircleIntersect (x :Number, y :Number, rad :Number) :Number
    {
        var dx :Number = x1 - x2;
        var dy :Number = y1 - y2;
        var d :Number = (x1 - x) * (y2 - y) - (x2 - x) * (y1 - y);
        var delta :Number = rad * rad * mag * mag - d * d;
        if (delta < 0) {
            return -1;
        } else if (delta == 0) {
            return relDot(x + d * dy / mag * mag, y - d * dx / mag * mag);
        }
        var sdelta :Number = Math.sqrt(delta);
        var xx1 :Number = x + (d * dy + (dy < 0 ? -1 : 1) * dx * sdelta) / mag * mag;
        var yy1 :Number = y - (d * dx + Math.abs(dy) * sdelta) / mag * mag;
        var xx2 :Number = x + (d * dy - (dy < 0 ? -1 : 1) * dx * sdelta) / mag * mag;
        var yy2 :Number = y - (d * dx - Math.abs(dy) * sdelta) / mag * mag;
        return Math.max(0, Math.min(relDot(xx1, yy1), relDot(xx2, yy2)));
    }

    /**
     * Determins the minimal distance between two line segments.
     */
    public function getLineDist (line :LineData) :Number
    {
        var dist2 :Number = getSegmentDist2(line.x1, line.y1);
        dist2 = Math.min(dist2, getSegmentDist2(line.x2, line.y2));
        dist2 = Math.min(dist2, line.getSegmentDist2(x1, y1));
        dist2 = Math.min(dist2, line.getSegmentDist2(x2, y2));
        return Math.sqrt(dist2);
    }

    /**
     * Determins the minimal distance between a polygon and line.
     */
    public function getMinimalPolyDist (lines :Array) :Array
    {
        var min :Number = Number.MAX_VALUE;
        var minLd :LineData;
        for each (var ld :LineData in lines) {
            var dist :Number = getLineDist(ld);
            if (dist < min) {
                min = dist;
                minLd = ld;
            }
        }
        return [ min, minLd ];
    }

    /**
     * Returns true if this point is outside the line.
     */
    public function isOutside (x :Number, y :Number) :Boolean
    {
        //return getDist(x, y) > 0;
        return x * nx + y * ny + D > 0;
    }

    /**
     * Returns true if this point is inside the line.
     */
    public function isInside (x :Number, y :Number) :Boolean
    {
        //return getDist(x, y) <= 0;
        return x * nx + y * ny + D <= 0;
    }

    /**
     * Return true if the line is completely outside.
     */
    public function isLineOutside (line :LineData) :Boolean
    {
        //return isOutside(line.x1, line.y1) && isOutside(line.x2, line.y2);
        return (line.x1 * nx + line.y1 * ny + D > 0) && (line.x2 * nx + line.y2 * ny + D > 0);
    }

    /**
     * Return true if the line is completely inside.
     */
    public function isLineInside (line :LineData) :Boolean
    {
        //return isInside(line.x1, line.y1) && isInside(line.x2, line.y2);
        return (line.x1 * nx + line.y1 * ny + D <= 0) && (line.x2 * nx + line.y2 * ny + D <= 0);
    }

    /**
     * Returns true if any point of the supplied polygone is outside the line.
     */
    public function anyOutside (lines :Array) :Boolean
    {
        for each (var line :LineData in lines) {
            //if (isOutside(line.x1, line.y1)) {
            if (line.x1 * nx + line.y1 * ny + D > 0) {
                return true;
            }
        }
        return false;
    }

    /**
     * Returns true if any point of the supplied polygon is inside the line.
     */
    public function anyInside (lines :Array) :Boolean
    {
        for each (var line :LineData in lines) {
            //if (isInside(line.x1, line.y1)) {
            if (line.x1 * nx + line.y1 * ny + D <= 0) {
                return true;
            }
        }
        return false;
    }

    /**
     * Returns true if l1 and l2 are on opposite sides of the line but neither intersecting.
     */
    public function didCross (l1 :LineData, l2 :LineData) :Boolean
    {
        var start :Boolean = isInside(l1.x1, l1.y1);
        if (start != isInside(l1.x2, l1.y2)) {
            return false;
        }
        var end :Boolean = isInside(l2.x1, l2.y1);
        if (end != isInside(l2.x2, l2.y2)) {
            return false;
        }
        return start != end;
    }

    /**
     * Returns true if l2 is intersecting or on the opposite of the line as l1.
     */
    public function didSimpleCross (l1 :LineData, l2 :LineData) :Boolean
    {
        var start :Boolean = isInside(l1.x1, l1.y1);
        if (start != isInside(l1.x2, l1.y2)) {
            return false;
        }
        return start != isInside(l2.x1, l2.y1) || start != isInside(l2.x2, l2.y2);
    }

    /**
     * Returns true if l1 translated by xd, yd crosses the line without intersecting.
     */
    public function didCrossDelta (l1 :LineData, xd :Number, yd :Number) :Boolean
    {
        var start :Boolean = isInside(l1.x1, l1.y1);
        if (start != isInside(l1.x2, l1.y2)) {
            return false;
        }
        var end :Boolean = isInside(l1.x1 + xd, l1.y1 + yd);
        if (end != isInside(l1.x2 + xd, l1.y2 + yd)) {
            return false;
        }
        return start != end;
    }

    /**
     * Returns true if any line in the polygon crosses this line after translation.
     */
    public function didPolyCrossDelta (lines :Array, xd :Number, yd :Number) :Boolean
    {
        for each (var line :LineData in lines) {
            if (didCrossDelta(line, xd, yd)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Returns true if x,y is on the line segment.
     */
    public function isOn (x :Number, y :Number) :Boolean
    {
        return Math.abs(x * nx + y * ny + D) < EPSILON && relDot(x, y) <= mag && relDot(x, y) >= 0;
    }

    /**
     * Returns true if the supplied line intersects the y component of our line segment.
     */
    public function yIntersecting (line :LineData) :Boolean
    {
        return (line.y1 >= y1 && line.y1 <= y2) || (line.y1 >= y2 && line.y1 <= y1) ||
            (line.y2 >= y1 && line.y2 <= y2) || (line.y2 >= y2 && line.y2 <= y1) ||
            (line.y1 >= y1 && line.y2 <= y2) || (line.y1 >= y2 && line.y2 <= y1);
    }

    /**
     * Returns true if the supplied line intersects the x component of our line segment.
     */
    public function xIntersecting (line :LineData) :Boolean
    {
        return (line.x1 >= x1 && line.x1 <= x2) || (line.x1 >= x2 && line.x1 <= x1) ||
            (line.x2 >= x1 && line.x2 <= x2) || (line.x2 >= x2 && line.x2 <= x1) ||
            (line.x1 >= x1 && line.x2 <= x2) || (line.x1 >= x2 && line.x2 <= x1);
    }

    /**
     * Returns true if we are intersecting any part of the supplied polygon or are entirely
     * contained in the polygon.
     */
    public function polyIntersecting (lines :Array) :Boolean
    {
        var p1inside :Boolean = lines.length > 2;
        var p2inside :Boolean = lines.length > 2;
        for each (var line :LineData in lines) {
            //var o1 :Boolean = line.isInside(x1, y1);
            //var o2 :Boolean = line.isInside(x2, y2);
            var o1 :Boolean = x1 * line.nx + y1 * line.ny + line.D <= 0;
            var o2 :Boolean = x2 * line.nx + y2 * line.ny + line.D <= 0;
            //if (o1 != o2 && isInside(line.x1, line.y1) != isInside(line.x2, line.y2)) {
            if (o1 != o2 && ((line.x1 * nx + line.y1 * ny + D <= 0) !=
                    (line.x2 * nx + line.y2 * ny + D <= 0))) {
                return true;
            }
            p1inside &&= o1;
            p2inside &&= o2;
        }
        return p1inside || p2inside;
    }

    /**
     * Returns the distance to the minimal intersecting distance of this line and the supplied
     * polygon.
     */
    public function polyIntersect (lines :Array) :Array
    {
        var closehit :Number = Number.MAX_VALUE;
        var p1inside :Boolean = true;
        var l :LineData;
        for each (var line :LineData in lines) {
            if (isIntersecting(line)) {
                var hit :Number = findIntersect(line);
                if (hit < closehit) {
                    closehit = hit;
                    l = line;
                }
            }
            if (p1inside && !line.isInside(x1, y1)) {
                p1inside = false;
            }
        }
        if (p1inside) {
            closehit = 0;
        }
        return [ closehit, l ];
    }

    /**
     * Returns true if this line segment intersects the supplied line segment.
     */
    public function isIntersecting (line :LineData) :Boolean
    {
        //return !(isOutside(line.x1, line.y1) == isOutside(line.x2, line.y2) ||
        //    line.isOutside(x1, y1) == line.isOutside(x2, y2));
        return !(((line.x1 * nx + line.y1 * ny + D <= 0) ==
                (line.x2 * nx + line.y2 * ny + D <= 0)) ||
            ((x1 * line.nx + y1 * line.ny + line.D <= 0) ==
                (x2 * line.nx + y2 * line.ny + line.D <= 0)));
    }

    /**
     * Returns the distance on this line to the intersection point.
     */
    public function findIntersect (line :LineData) :Number
    {
        var x_ :Number = x2 - x1;
        var y_ :Number = y2 - y1;
        var ox_ :Number = line.x2 - line.x1;
        var oy_ :Number = line.y2 - line.y1;
        var den :Number = oy_ * x_ - ox_ * y_;
        if (den == 0) {
            return Number.MAX_VALUE;
        }
        return (oy_ * line.x1 + ox_ * y1 - oy_ * x1 - ox_ * line.y1) / den;
    }

    public function toString () :String
    {
        return "line: (" + x1.toFixed(3) + ", " + y1.toFixed(3) +
                    ")->(" + x2.toFixed(3) + ", " + y2.toFixed(3) + ") N(" +
                    nx.toFixed(3) + ", " + ny.toFixed(3) + ") D: " + D.toFixed(3);
    }

    protected var _connected :Dictionary;
}
}
