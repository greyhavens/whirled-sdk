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

package com.whirled.contrib.platformer.editor {

import com.whirled.contrib.platformer.display.Layer;
import com.whirled.contrib.platformer.display.Metrics;

/**
 * A layer that displays the tile grid.
 */
public class GridLayer extends Layer
{
    public function GridLayer ()
    {
        redraw(_oldScale);
        mouseEnabled = false;
        mouseChildren = false;
    }

    override public function update (nX :Number, nY :Number, scale :Number = 1) :void
    {
        if (scale != _oldScale) {
            redraw(scale);
            _oldScale = scale;
        }
        x = Math.floor(-nX);
        if (x < 0) {
            x %= Metrics.TILE_SIZE;
        }
        y = Math.floor(-nY);
        if (nY < 0) {
            y %= Metrics.TILE_SIZE;
        }
    }

    protected function redraw (scale :Number) :void
    {
        graphics.clear();
        graphics.lineStyle(0, 0x000000, 0.5);
        for (var ii :int = 0; ii <= Metrics.WINDOW_WIDTH * scale; ii++) {
            graphics.moveTo(ii * Metrics.TILE_SIZE / scale, Metrics.DISPLAY_HEIGHT);
            graphics.lineTo(ii * Metrics.TILE_SIZE / scale, -Metrics.TILE_SIZE);
        }
        for (ii = 0; ii <= Metrics.WINDOW_HEIGHT * scale; ii++) {
            graphics.moveTo(0, ii * Metrics.TILE_SIZE / scale);
            graphics.lineTo(
                (Metrics.DISPLAY_WIDTH + Metrics.TILE_SIZE), ii * Metrics.TILE_SIZE / scale);
        }
    }

    protected var _oldScale :Number = 1;
}
}
