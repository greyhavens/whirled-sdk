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

import com.whirled.contrib.platformer.piece.Hover;

public class HoverSprite extends DynamicSprite
{
    public static const IDLE :String = "idle";
    public static const ACTIVE :String = "active";
    public static const OVER :String = "over";
    public static const OFF :String = "off";

    public function HoverSprite (h :Hover, disp :DisplayObject = null)
    {
        _hover = h;
        super(h, disp);
        if (_disp != null) {
            _disp.x = h.width/2 * Metrics.TILE_SIZE;
            addChild(_disp);
        }
    }

    override public function update (delta :Number) :void
    {
        super.update(delta);
        if (_state == ACTIVE || _state == OVER) {
            if (!_hover.hovered) {
                changeState(OFF);
                _state = IDLE;
            }
        } else if (_hover.hovered) {
            changeState(ACTIVE);
            _state = OVER;
        }
    }

    protected var _hover :Hover;
}
}
