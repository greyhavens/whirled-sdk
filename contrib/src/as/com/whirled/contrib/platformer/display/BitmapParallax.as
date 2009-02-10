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

import flash.geom.Point;
import flash.geom.Rectangle;

import com.whirled.contrib.platformer.client.ClientPlatformerContext;
import com.whirled.contrib.platformer.util.Metrics;

public class BitmapParallax
{
    public var updated :Boolean = true;
    public var rect :Rectangle;
    public var pt :Point;
    public var bd :BitmapData;
    public var blend :Boolean = true;

    public function BitmapParallax (disp :DisplayObject, sX :int = 1, sY :int = 1, oX :int = 0,
            oY :int = 0, tileY :Boolean = false)
    {
        _scaleX = sX;
        _scaleY = sY;
        _tileY = tileY;
        pt = new Point(oX, oY);
        bd = new BitmapData(Math.floor(disp.width), Math.floor(disp.height), true, 0x00000000);
        bd.draw(disp);
        rect = new Rectangle(-1, -1, Math.min(bd.width, Metrics.DISPLAY_WIDTH),
            Math.min(bd.height, Metrics.DISPLAY_HEIGHT));
        //trace("BP: " + rect + " source: (" + bd.width + ", " + bd.height + ")");
    }

    public function shutdown () :void
    {
        bd.dispose();
    }

    public function update (nX :Number, nY :Number) :void
    {
        nY -= ClientPlatformerContext.boardSprite.minY * Metrics.TILE_SIZE;
        var newX :int = (pt.x + (_scaleX == 0 ? 0 : Math.floor(nX / _scaleX))) % bd.width;
        var newY :int = pt.y - (_scaleY == 0 ? 0 : Math.floor(nY / _scaleY));
        if (_tileY) {
            newY = newY % bd.height;
        }

        if (rect.x != newX) {
            rect.x = newX;
            updated = true;
        }
        if (rect.y != newY) {
            rect.y = newY;
            updated = true;
        }
    }

    public function redraw (dest :BitmapData) :void
    {
        updated = false;
        var r :Rectangle = rect.clone();
        var p :Point = new Point();
        p.y = Metrics.DISPLAY_HEIGHT - rect.height - r.y;
        r.y = 0;
        if (_tileY) {
            while (p.y > 0) {
                p.y -= r.height;
            }
            while (p.y < 0) {
                if (p.y + r.height > 0) {
                    r.y = -p.y;
                    r.height += p.y;
                    p.y = 0;
                } else {
                    p.y += r.height;
                }
            }
        } else if (_scaleY != 0) {
            if (p.y > Metrics.DISPLAY_HEIGHT) {
                return;
            } else if (p.y < 0) {
                if (-p.y > r.height) {
                    return;
                }
                r.y = -p.y;
                p.y = 0;
            }
        }
        r.height = Math.min(Math.min(r.height, bd.height - r.y), Metrics.DISPLAY_HEIGHT - p.y);
        do {
            p.x = 0;
            r.x = rect.x;
            r.width = Math.min(rect.width, bd.width - r.x);
            do {
                dest.copyPixels(bd, r, p, null, null, blend);
                p.x += r.width;
                r.width = Math.min(bd.width, Metrics.DISPLAY_WIDTH - p.x);
                r.x = 0;
            } while (_scaleX > 0 && p.x < Metrics.DISPLAY_WIDTH);
            p.y += r.height;
            r.height = Math.min(bd.height, Metrics.DISPLAY_HEIGHT - p.y);
            r.y = 0;
        } while (_tileY && _scaleY > 0 && p.y < Metrics.DISPLAY_HEIGHT);
    }

    protected var _scaleX :Number;
    protected var _scaleY :Number;
    protected var _tileY :Boolean;
}
}
