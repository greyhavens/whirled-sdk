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

public class ParallaxLayer extends Layer
{
    public function ParallaxLayer (sX :int = 1, sY :int = 1)
    {
        _scaleX = sX;
        _scaleY = sY;
    }

    public override function update (nX :Number, nY :Number, scale :Number = 1) :void
    {
        nX = (_scaleX == 0) ? 0 : nX / _scaleX;
        nY = (_scaleY == 0) ? 0 : nY / _scaleY;
        super.update(nX, nY);
    }

    /** The ratio of movement from the main layer to this parallax layer. */
    protected var _scaleX :int;
    protected var _scaleY :int;
}
}
