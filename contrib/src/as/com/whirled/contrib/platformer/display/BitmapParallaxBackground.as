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

import com.whirled.contrib.platformer.client.ClientPlatformerContext;
import com.whirled.contrib.platformer.util.Metrics;

public class BitmapParallaxBackground extends Layer
{
    public function BitmapParallaxBackground ()
    {
        _bd = new BitmapData(Metrics.DISPLAY_WIDTH, Metrics.DISPLAY_HEIGHT, true, 0x00000000);
        addChild(new Bitmap(_bd));
        _enabled = ClientPlatformerContext.prefs.backgroundScrolling;
    }

    public function addNewLayer (disp :DisplayObject, scaleX :int = 1, scaleY :int = 1,
            offX :int = 0, offY :int = 0, tileY :Boolean = false) :void
    {
        if (disp == null) {
            return;
        }
        _layers.push(new BitmapParallax(disp, scaleX, scaleY, offX, offY, tileY));
        if (_layers.length == 1) {
            _layers[0].blend = false;
        }
    }

    public function setEnabled (enabled :Boolean) :void
    {
        if (_enabled && !enabled) {
            _hasDrawn = false;
        }
        _enabled = enabled;
        ClientPlatformerContext.prefs.backgroundScrolling = enabled;
    }

    override public function update (nX :Number, nY :Number, scale :Number = 1) :void
    {
        if (!_enabled && _hasDrawn) {
            return;
        }
        var updated :Boolean = false;
        for each (var layer :BitmapParallax in _layers) {
            if (!_enabled) {
                nY = ClientPlatformerContext.boardSprite.minY * Metrics.TILE_SIZE;
            }
            layer.update(nX, nY);
            updated = updated || layer.updated;
        }
        if (updated) {
            _bd.lock();
            for each (layer in _layers) {
                layer.redraw(_bd);
            }
            _bd.unlock();
            _hasDrawn = true;
        }
    }

    protected var _bd :BitmapData;
    protected var _enabled :Boolean = true;
    protected var _hasDrawn :Boolean;

    protected var _layers :Array = new Array();
}
}
