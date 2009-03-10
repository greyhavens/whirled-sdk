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
            setDamageState(DAMAGE_2, DAMAGED_2);
        } else if (_dg.health < 2 * _dg.startHealth / 3) {
            setDamageState(DAMAGE_1, DAMAGED_1);
        } else {
            super.idle();
        }
    }

    protected function setDamageState (damage :int, damaged :int) :void
    {
        if (_state != damaged) {
            if (_state > -1) {
                changeState(damage);
                playSoundEffect(_gate.deathSoundEffect);
                _state = damaged;
            } else {
                changeState(damaged);
            }
        }
    }

    override protected function getStateFrame (state :int) :Object
    {
        if (state < GS_COUNT) {
            return super.getStateFrame(state);
        }
        return DGS_STATES[state - GS_COUNT];
    }

    protected var _dg :DestructableGate;

    protected static const DAMAGE_1 :int = GS_COUNT + 0; // damage1
    protected static const DAMAGED_1 :int = GS_COUNT + 1; // damaged1
    protected static const DAMAGE_2 :int = GS_COUNT + 2; // damage2
    protected static const DAMAGED_2 :int = GS_COUNT + 3; // damaged2

    protected static const DGS_STATES :Array =
        [ "damage1", "damaged1", "damage2", "damaged2" ];
}
}
