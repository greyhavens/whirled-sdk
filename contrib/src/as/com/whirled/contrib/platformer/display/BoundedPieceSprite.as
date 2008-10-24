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

package com.whirled.contrib.platformer.display {

import flash.display.DisplayObject;
import flash.display.Shape;

import flash.geom.Point;

import com.whirled.contrib.platformer.piece.Piece;
import com.whirled.contrib.platformer.piece.BoundData;
import com.whirled.contrib.platformer.piece.BoundedPiece;
import com.whirled.contrib.platformer.util.Metrics;

public class BoundedPieceSprite extends PieceSprite
{
    public function BoundedPieceSprite (p :BoundedPiece, disp :DisplayObject = null)
    {
        super(p, disp);
        _bpiece = p;
    }

    override protected function createDetails () :void
    {
        super.createDetails();
        if (_bounds != null) {
            _details.removeChild(_bounds);
        }
        if (_bpiece.numBounds() < 3) {
            return;
        }
        _bounds = new Shape();
        var start :Point;
        var idx :int = 0;
        for each (var end :Point in _bpiece.getBounds()) {
            if (start == null) {
                start = end;
                _bounds.graphics.moveTo(start.x * Metrics.TILE_SIZE, -start.y * Metrics.TILE_SIZE);
            } else {
                _bounds.graphics.lineTo(end.x * Metrics.TILE_SIZE, -end.y * Metrics.TILE_SIZE);
            }
            _bounds.graphics.lineStyle(0, BoundData.getColor(_bpiece.getBound(idx++)));
        }
        _bounds.graphics.lineTo(start.x * Metrics.TILE_SIZE, -start.y * Metrics.TILE_SIZE);
        _details.addChild(_bounds);
    }

    protected var _bpiece :BoundedPiece;
    protected var _bounds :Shape;
}
}
