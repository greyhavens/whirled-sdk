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

import com.whirled.contrib.platformer.piece.DestructableGate;

public class DestructableGateSprite extends GateSprite
{
    public static const DAMAGE_1 :String = "damage1";
    public static const DAMAGED_1 :String = "damaged1";
    public static const DAMAGE_2 :String = "damage2";
    public static const DAMAGED_2 :String = "damaged2";

    public function DestructableGateSprite (dg :DestructableGate, disp :DisplayObject = null)
    {
        _dg = dg;
        super(dg, disp);
    }

    override public function update (delta :Number) :void
    {
        super.update(delta);
        if (_dg.wasHit) {
            showHit();
        }
    }

    override protected function idle () :void
    {
        if (_dg.health < _dg.startHealth/3) {
            if (_state != DAMAGED_2) {
                changeState(DAMAGE_2);
                _state == DAMAGED_2;
            }
        } else if (_dg.health < 2 * _dg.startHealth / 3) {
            if (_state != DAMAGED_1) {
                changeState(DAMAGE_1);
                _state == DAMAGED_1;
            }
        } else {
            super.idle();
        }
    }

    protected var _dg :DestructableGate;
}
}
