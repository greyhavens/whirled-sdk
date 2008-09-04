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

public class BitmapParallaxBackground extends Layer
{
    public function BitmapParallaxBackground ()
    {
        _bd = new BitmapData(Metrics.DISPLAY_WIDTH, Metrics.DISPLAY_HEIGHT, true, 0x00000000);
        addChild(new Bitmap(_bd));
    }

    public function addNewLayer (
        disp :DisplayObject, scaleX :int = 1, scaleY :int = 1, offX :int = 0, offY :int = 0) :void
    {
        _layers.push(new BitmapParallax(disp, scaleX, scaleY, offX, offY));
        if (_layers.length == 1) {
            _layers[0].blend = false;
        }
    }

    override public function update (nX :Number, nY :Number, scale :Number = 1) :void
    {
        var updated :Boolean = false;
        for each (var layer :BitmapParallax in _layers) {
            layer.update(nX, nY);
            updated = updated || layer.updated;
        }
        _bd.lock();
        if (updated) {
            for each (layer in _layers) {
                layer.redraw(_bd);
            }
        }
        _bd.unlock();
    }

    protected var _bd :BitmapData;

    protected var _layers :Array = new Array();
}
}
