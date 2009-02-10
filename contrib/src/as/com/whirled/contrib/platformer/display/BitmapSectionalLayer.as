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

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;

import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import com.whirled.contrib.platformer.piece.Piece;
import com.whirled.contrib.platformer.util.Metrics;
import com.whirled.contrib.platformer.util.SectionalIndex;

public class BitmapSectionalLayer extends PieceSpriteLayer
{
    public function BitmapSectionalLayer (secWidth :int, secHeight :int)
    {
        _sindex = new SectionalIndex(secWidth, secHeight);
        _bd = new BitmapData(Metrics.DISPLAY_WIDTH, Metrics.DISPLAY_HEIGHT, true, 0x00000000);
        var width :int = Math.ceil(Metrics.WINDOW_WIDTH / secWidth);
        var height :int = Math.ceil(Metrics.WINDOW_HEIGHT / secHeight);
        var poolSize :int = width * height * 9 + 1;
        _pool = new BitmapPool(poolSize, secWidth * Metrics.TILE_SIZE,
                secHeight * Metrics.TILE_SIZE, generateBitmap);
        //        10, secWidth * Metrics.TILE_SIZE, secHeight * Metrics.TILE_SIZE, generateBitmap);
        addChild(new Bitmap(_bd));
    }

    override public function shutdown () :void
    {
        clear();
    }

    override public function addPieceSprite (ps :PieceSprite) :void
    {
        var p :Piece = ps.getPiece();
        for (var xx :int = _sindex.getSectionXFromTile(p.sX),
             xn :int = _sindex.getSectionXFromTile(p.sX + p.sWidth);
             xx <= xn; xx++) {
            for (var yy :int = _sindex.getSectionYFromTile(p.sY),
                 yn :int = _sindex.getSectionYFromTile(p.sY + p.sHeight);
                 yy <= yn; yy++) {
                var idx :int = _sindex.getSectionIndex(xx, yy);
                if (_sections[idx] == null) {
                    _sections[idx] = new Array();
                }
                _sections[idx].push(ps);
                _pool.clearIndex(idx);
            }
        }

//        trace("adding piece: " + ps.getPiece() + " to section: " + idx);
    }

    override public function clear () :void
    {
        _sections = new Array();
        _pool.clear();
    }

    override public function update (nX :Number, nY :Number, scale :Number = 1) :void
    {
        var sx :int = Math.floor(nX);
        var sy :int = Math.floor(nY);
        if (_oldnX == sx && _oldnY == sy) {
            return;
        }
        _oldnX = sx;
        _oldnY = sy;
        sx /= Metrics.TILE_SIZE;
        sy /= Metrics.TILE_SIZE;
        var sw :int = _sindex.getSectionWidth();
        var sh :int = _sindex.getSectionHeight();
        var rect :Rectangle = new Rectangle(0, 0, Metrics.DISPLAY_WIDTH, Metrics.DISPLAY_HEIGHT);
        var pt :Point = new Point();
        _bd.lock();
        var oy :int = 0;
        for (var yy :int = _sindex.getSectionYFromTile(sy),
             yn :int = _sindex.getSectionYFromTile(sy + Metrics.WINDOW_HEIGHT);
             yy <= yn; yy++) {
            var ox :int = 0;
            for (var xx :int = _sindex.getSectionXFromTile(sx),
                 xn :int = _sindex.getSectionXFromTile(sx + Metrics.WINDOW_WIDTH);
                 xx <= xn; xx++) {
                var idx :int = _sindex.getSectionIndex(xx, yy);
                var bd :BitmapData;
                if (_sections[idx] != null) {
                    bd = _pool.getBitmap(idx);
                } else {
                    bd = null;
                }
                if (ox == 0) {
                    rect.x = _oldnX % (sw * Metrics.TILE_SIZE);
                    rect.width = (sw * Metrics.TILE_SIZE) - rect.x;
                } else {
                    rect.x = 0;
                    rect.width = Math.min(Metrics.DISPLAY_WIDTH - ox, sw * Metrics.TILE_SIZE);
                }
                if (oy + sh * Metrics.TILE_SIZE <= Metrics.DISPLAY_HEIGHT) {
                    rect.y = 0;
                } else {
                    rect.y = oy + sh * Metrics.TILE_SIZE - Metrics.DISPLAY_HEIGHT;
                }
                if (oy == 0) {
                    rect.height = sh * Metrics.TILE_SIZE - (_oldnY % (sh * Metrics.TILE_SIZE));
                } else {
                    rect.height = sh * Metrics.TILE_SIZE - rect.y;
                }
                pt.x = ox;
                pt.y = Metrics.DISPLAY_HEIGHT - oy - rect.height;
                if (bd != null) {
                    _bd.copyPixels(bd, rect, pt);
                } else {
                    rect.x = pt.x;
                    rect.y = pt.y;
                    _bd.fillRect(rect, 0);
                }
//                trace("copy pixels " + idx + " r:" + rect + ", pt:" + pt);
                ox += rect.width;
            }
            oy += rect.height;
        }
        _bd.unlock();

    }

    protected function generateBitmap (idx :int, bd :BitmapData) :void
    {
        bd.fillRect(new Rectangle(0, 0, bd.width, bd.height), 0);
        var sh :int = _sindex.getSectionHeight();
        var sw :int = _sindex.getSectionWidth();
        var offx :int = _sindex.getSectionX(idx) * sw;
        var offy :int = _sindex.getSectionY(idx) * sh;
        for each (var ps :PieceSprite in _sections[idx]) {
            var bitmap :BitmapData = ps.getBitmap();
            if (bitmap == null) {
                continue;
            }
            var p :Piece = ps.getPiece();
            //var x :int = p.x - 1 - offx;
            //var y :int = sh + offy - p.y - p.height - 2;
            var x :int = offx - (p.orient == 0 ? p.sX : p.x - (p.nudgeW ? 1 : 0));
            var y :int = sh + offy - p.y - p.height - (p.nudgeH ? 1 : 0);
            var r :Rectangle = new Rectangle(Math.max(x, 0) * Metrics.TILE_SIZE,
                Math.max(-y, 0) * Metrics.TILE_SIZE,
                Math.min(bitmap.width, (sw - Math.max(-x, 0)) * Metrics.TILE_SIZE),
                Math.min(bitmap.height, (sh - Math.max(y, 0)) * Metrics.TILE_SIZE));
            var pt :Point = new Point(Math.max(-x, 0) * Metrics.TILE_SIZE, Math.max(y, 0) * Metrics.TILE_SIZE);
            bd.copyPixels(bitmap, r, pt, null, null, true);
            /*
            var mat :Matrix = disp.transform.matrix.clone();
            mat.translate((p.x - offx) * Metrics.TILE_SIZE, (sh - p.y + offy) * Metrics.TILE_SIZE);
//            trace("drawing piece (" + p.x + ", " + p.y + ") to translation (" + mat.tx + ", " +
//                mat.ty + ")");
            bd.draw(disp, mat);
            */
        }
    }

    protected var _oldnX :int = -1;
    protected var _oldnY :int = -1;

    protected var _sindex :SectionalIndex;
    protected var _sections :Array = new Array();
    protected var _bd :BitmapData;
    protected var _pool :BitmapPool;
}
}
