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

import flash.events.Event;

import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import com.whirled.contrib.platformer.util.Metrics;

public class ParallaxBitmap extends Layer
{
    public function ParallaxBitmap (sX :int = 1, sY :int = 1, oX :int = 0, oY :int = 0)
    {
        _bd = new BitmapData(Metrics.DISPLAY_WIDTH, Metrics.DISPLAY_HEIGHT, true, 0x00000000);
        _scaleX = sX;
        _scaleY = sY;
        _pt = new Point(oX, oY);
        //y = -Metrics.DISPLAY_HEIGHT;
    }

    public function setDisp (disp :DisplayObject) :void
    {
        trace("Adding new parallax bitmap layer (" + disp.width + ", " + disp.height + ")");
        _rect = new Rectangle(0, 0, Math.min(disp.width, Metrics.DISPLAY_WIDTH),
                Math.min(disp.height, Metrics.DISPLAY_HEIGHT));
        disp.addEventListener(Event.COMPLETE, onComplete);
        _source = new BitmapData(disp.width, disp.height, true, 0x00000000);
        //bitmapData.copyPixels(_source, _rect, POINT);
        //_bd.draw(disp);
        var b :Bitmap = new Bitmap(_bd);
        trace("created bitmap (" + b.width + ", " + b.height + ")");
        addChild(b);
        _pt.x = Metrics.DISPLAY_WIDTH -_rect.width + _pt.x;
        _pt.y = Metrics.DISPLAY_HEIGHT - _rect.height - _pt.y;
        //addChild(disp);
    }

    override public function update (nX :Number, nY :Number, scale :Number = 1) :void
    {
        nX = (_scaleX == 0) ? 0 : nX / _scaleX;
        nY = (_scaleY == 0) ? 0 : nY / _scaleY;
        var update :Boolean = false;
        if (_rect.x != Math.floor(nX)) {
            _rect.x = Math.floor(nX);
            update = true;
        }
        if (_rect.y != Math.floor(nY)) {
            _rect.y = Math.floor(nY);
            update = true;
        }
        if (update) {
            _bd.copyPixels(_source, _rect, _pt);
        }
    }

    protected function onComplete (event :Event) :void
    {
        _source.draw(event.target as DisplayObject);
        _bd.copyPixels(_source, _rect, _pt);
        event.target.removeEventListener(Event.COMPLETE, arguments.callee);
    }

    protected var _curX :int;
    protected var _curY :int;

    protected var _source :BitmapData;
    protected var _rect :Rectangle;
    protected var _bd :BitmapData;
    protected var _pt :Point;

    protected var _scaleX :int;
    protected var _scaleY :int;
}
}
