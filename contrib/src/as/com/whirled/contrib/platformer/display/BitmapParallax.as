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

import com.whirled.contrib.platformer.util.Metrics;

public class BitmapParallax
{
    public var updated :Boolean = true;
    public var rect :Rectangle;
    public var pt :Point;
    public var bd :BitmapData;
    public var blend :Boolean = true;

    public function BitmapParallax (
        disp :DisplayObject, sX :int = 1, sY :int = 1, oX :int = 0, oY :int = 0)
    {
        _scaleX = sX;
        _scaleY = sY;
        pt = new Point(oX, oY);
        bd = new BitmapData(Math.floor(disp.width), Math.floor(disp.height), true, 0x00000000);
        bd.draw(disp);
        rect = new Rectangle(-1, -1, Math.min(bd.width, Metrics.DISPLAY_WIDTH),
            Math.min(bd.height, Metrics.DISPLAY_HEIGHT));
        //trace("BP: " + rect + " source: (" + bd.width + ", " + bd.height + ")");
        pt.x = Metrics.DISPLAY_WIDTH - rect.width + pt.x;
        pt.y = Metrics.DISPLAY_HEIGHT - rect.height - pt.y;
    }

    public function update (nX :Number, nY :Number) :void
    {
        var newX :int = (_scaleX == 0) ? 0 : Math.floor(nX / _scaleX) % bd.width;
        var newY :int = (_scaleY == 0) ? 0 : Math.floor(nY / _scaleY) % bd.height;
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
        var r :Rectangle = rect.clone();
        r.width = Math.min(r.width, bd.width - r.x);
        r.height = Math.min(r.height, bd.height - r.y);
        var p :Point = pt.clone();
        updated = false;
        do {
            p.x = pt.x;
            do {
                dest.copyPixels(bd, r, p, null, null, blend);
                p.x += r.width;
                r.width = Math.min(bd.width, Metrics.DISPLAY_WIDTH - p.x);
                r.x = 0;
            } while (_scaleX > 0 && p.x < Metrics.DISPLAY_WIDTH);
            p.y += r.height;
            r.height = Math.min(bd.height, Metrics.DISPLAY_HEIGHT - p.y);
            r.y = 0;
        } while (_scaleY > 0 && p.y < Metrics.DISPLAY_HEIGHT);
    }

    protected var _scaleX :Number;
    protected var _scaleY :Number;
}
}
