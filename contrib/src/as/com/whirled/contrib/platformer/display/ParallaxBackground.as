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

/**
 * A layer that displays one or more parallax background layers.
 */
public class ParallaxBackground extends Layer
{
    public static const USE_BITMAP :Boolean = true;
    public function addNewLayer (
            index :int, scaleX :int = 1, scaleY :int = 1, offX :int = 0, offY :int = 0) :void
    {
        if (USE_BITMAP) {
            _layers[index] = new ParallaxBitmap(scaleX, scaleY, offX, offY);
        } else {
            _layers[index] = new ParallaxLayer(scaleX, scaleY);
        }
        addChildAt(_layers[index], index);
    }

    public function addChildToLayer (disp :DisplayObject, index :int) :void
    {
        if (_layers[index] != null) {
            if (USE_BITMAP) {
                _layers[index].setDisp(disp);
            } else {
                disp.y = - disp.height;
                _layers[index].addChild(disp);
            }
        }
    }

    override public function update (nX :Number, nY :Number, scale :Number = 1) :void
    {
        if (USE_BITMAP) {
            _layers.forEach(function (layer :ParallaxBitmap, index :int, arr :Array) :void {
                layer.update(nX, nY);
            });
        } else {
            _layers.forEach(function (layer :ParallaxLayer, index :int, arr :Array) :void {
                layer.update(nX, nY);
            });
        }
    }

    /** Our parallax layers. */
    protected var _layers :Array = new Array();
}
}
