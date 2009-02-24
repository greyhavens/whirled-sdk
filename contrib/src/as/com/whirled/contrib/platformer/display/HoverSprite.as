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

import com.whirled.contrib.platformer.util.Metrics;

public class HoverSprite extends DynamicSprite
{
    public function HoverSprite (h :Hover, disp :DisplayObject = null)
    {
        super(h, disp);
        _hover = h;
        if (_disp != null) {
            _disp.x = h.width/2 * Metrics.TILE_SIZE;
            addChild(_disp);
        }
        update(0);
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
            playSoundEffect(_hover.hoverSoundEffect);
        }
    }

    override protected function getStateFrame (state :int) :Object
    {
        return HS_STATES[state];
    }

    protected var _hover :Hover;

    protected static const IDLE :int = 0; // idle
    protected static const ACTIVE :int = 1; // active
    protected static const OVER :int = 2; // over
    protected static const OFF :int = 3; // off

    protected static const HS_STATES :Array =
        [ "idle", "active", "over", "off" ];
}
}
