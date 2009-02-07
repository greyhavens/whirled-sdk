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

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Shape;
import flash.geom.Matrix;

import com.whirled.contrib.platformer.piece.Piece;
import com.whirled.contrib.platformer.util.Metrics;

/**
 * Visualizer for the base piece object.
 */
public class PieceSprite extends Sprite
{
    public function PieceSprite (piece :Piece, disp :DisplayObject = null, bitmap :Boolean = false)
    {
        _bitmap = bitmap;
        _piece = piece;
        if (!bitmap) {
            _disp = disp;
            if (_disp != null) {
                _disp.cacheAsBitmap = true;
                addChild(_disp);
            }
            update();
        }
    }

    public function update () :void
    {
        if (_bitmap) {
            return;
        }
        this.x = _piece.x * Metrics.TILE_SIZE;
        this.y = -_piece.y * Metrics.TILE_SIZE;
        updateDisp();
        if (_details != null && _details.parent != null) {
            createDetails();
        }
    }

    public function getPiece () :Piece
    {
        return _piece;
    }

    public function getDisp () :DisplayObject
    {
        updateDisp();
        return _disp;
    }

    public function getBitmap () :BitmapData
    {
        return _bd;
    }

    public function setBitmap (bd :BitmapData) :void
    {
        _bd = bd;
    }

    public function showDetails (show :Boolean) :void
    {
        if (show) {
            if (_details == null) {
                createDetails();
            }
            addChild(_details);
        } else if (_details != null) {
            removeChild(_details);
        }
    }

    protected function updateDisp () :void
    {
        if (_disp != null) {
            if (_piece.orient == 0) {
                _disp.x = 0;
                _disp.scaleX = 1.0;
            } else {
                _disp.scaleX = -1.0;
                _disp.x = _piece.width * Metrics.TILE_SIZE;
            }

        }
    }

    protected function createDetails () :void
    {
        _details = new Sprite();
        if (_piece.width > 0 && _piece.height > 0) {
            _details.graphics.lineStyle(0, 0x0000DD);
            _details.graphics.drawRect(
                    0, 0, _piece.width * Metrics.TILE_SIZE, -_piece.height * Metrics.TILE_SIZE);
        }
    }

    protected var _piece :Piece;
    protected var _disp : DisplayObject;
    protected var _details :Sprite;
    protected var _bd :BitmapData;
    protected var _bitmap :Boolean;
}
}
