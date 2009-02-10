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

import flash.display.Sprite;

import com.whirled.contrib.platformer.util.Metrics;

public class Layer extends Sprite
{
    public function update (nX :Number, nY :Number, scale :Number = 1) :void
    {
        if (_snapToPixel) {
            x = Math.floor(-nX);
            y = Math.floor(Metrics.DISPLAY_HEIGHT + nY);
        } else {
            x = -nX;
            y = Metrics.DISPLAY_HEIGHT + nY;
        }
    }

    public function shutdown () :void
    {
    }

    /** Set to true and all coordinates will be floored. */
    protected var _snapToPixel :Boolean = true;
}
}
