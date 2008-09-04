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

import flash.geom.Point;

/**
 * A piece that has a bounding polygon.
 */
public class BoundedPiece extends Piece
{
    public function BoundedPiece (defxml :XML = null, insxml :XML = null)
    {
        super(defxml, insxml);
        if (defxml != null) {
            if (defxml.child("bounds").length() > 0) {
                for each (var bxml :XML in defxml.child("bounds")[0].child("bound")) {
                    var bx :int = Math.max(0, Math.min(width, bxml.@x));
                    var by :int = Math.max(0, Math.min(height, bxml.@y));
                    var bt :int = bxml.@type;
                    if (orient == 1) {
                        bx = width - bx;
                        bt = BoundData.swapBounds(bt);
                    }
                    _boundPts.push(new Point(bx, by));
                    _boundSides.push(bt);
                }
            }
        }
    }

    public function numBounds () :int
    {
        return _boundPts == null ? 0 : _boundPts.length;
    }

    public function getBounds () :Array
    {
        return _boundPts;
    }

    public function getBound (side :int) :int
    {
        return (_boundSides == null || _boundSides.length <= side) ?
                BoundData.NONE : _boundSides[side];
    }

    public function getBoundLine (side :int) :Array
    {
        if (_boundPts == null) {
            return null;
        }
        return [ _boundPts[side % _boundPts.length], _boundPts[(side + 1) % _boundPts.length] ];
    }

    override public function xmlDef () :XML
    {
        var xml :XML = super.xmlDef();
        var bxml :XML = <bounds/>;
        for (var ii :int = 0; ii < _boundPts.length; ii++) {
            var bound :XML = <bound/>;
            bound.@x = _boundPts[ii].x;
            bound.@y = _boundPts[ii].y;
            bound.@type = _boundSides[ii];
            bxml.appendChild(bound);
        }
        xml.appendChild(bxml);
        return xml;
    }

    protected var _boundPts :Array = new Array();
    protected var _boundSides :Array = new Array();
}
}
