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

import com.whirled.contrib.platformer.piece.Gate;

public class GateSprite extends DynamicSprite
{
    public function GateSprite (g :Gate, disp :DisplayObject = null)
    {
        _gate = g;
        super(g, disp);
        if (disp != null) {
            addChild(disp);
            update(0);
        }
    }

    override public function update (delta :Number) :void
    {
        super.update(delta);
        if (_disp == null) {
            return;
        }
        if (_gate.open) {
            if (!isDead(_state)) {
                changeState(DEATH);
                _state = DEAD;
                playSoundEffect(_gate.deathSoundEffect);
            }
        } else {
            idle();
        }
    }

    protected function idle () :void
    {
        changeState(IDLE);
    }

    protected function isDead (state :int) :Boolean
    {
        return state == DEATH || state == DEAD;
    }

    override protected function getStateFrame (state :int) :Object
    {
        return GS_STATES[state];
    }

    protected var _gate :Gate;

    protected static const IDLE :int = 0; // idle
    protected static const DEATH :int = 1; // death
    protected static const DEAD :int = 2; // dead
    protected static const GS_COUNT :int = 3;

    protected static const GS_STATES :Array =
        [ "idle", "death", "dead" ];
}
}
