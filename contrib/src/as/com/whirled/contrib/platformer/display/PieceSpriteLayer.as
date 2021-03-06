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

/**
 * A simple layer that just displays every piece sprite added to it.
 */
public class PieceSpriteLayer extends Layer
{
    public function addPieceSprite (ps :PieceSprite) :void
    {
        addChild(ps);
    }

    public function clear () :void
    {
        for (var ii :int = numChildren - 1; ii >= 0; ii--) {
            removeChildAt(ii);
        }
    }
}
}
