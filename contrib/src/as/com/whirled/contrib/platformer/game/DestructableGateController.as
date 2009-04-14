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

package com.whirled.contrib.platformer.game {

import com.whirled.contrib.platformer.PlatformerContext;
import com.whirled.contrib.platformer.game.Collision;
import com.whirled.contrib.platformer.net.ShotMessage;
import com.whirled.contrib.platformer.piece.DestructableGate;
import com.whirled.contrib.platformer.piece.Dynamic;

public class DestructableGateController extends GateController
    implements ShootableController
{
    public function DestructableGateController (dg :DestructableGate, controller :GameController)
    {
        super(dg, controller);
        _dg = dg;
    }

    public function doesHit (x :Number = NaN, y :Number = NaN, source :Object = null) :Collision
    {
        return _dg.health > 0 ? _dg.hitCollision : _dg.missCollision;
    }

    public function doHit (damage :Number, owner :int, inter :int, sowner :int) :void
    {
        if ((!_dg.playerImpervious && inter == Dynamic.ENEMY) || inter == Dynamic.GLOBAL) {
            if (owner == PlatformerContext.myId) {
                _dg.health -= damage;
                if (owner == sowner) {
                    PlatformerContext.net.sendMessage(
                            ShotMessage.shotHit(_dg.id, damage, inter, sowner));
                }
                _dg.wasHit = true;
            } else if (sowner != PlatformerContext.myId) {
                _dg.health -= damage;
            } else {
                _dg.wasHit = true;
            }
        }
    }

    public function doesCollide () :Boolean
    {
        return _dg.health > 0;
    }

    public function getCenterX () :Number
    {
        return _dg.x + _dg.width/2;
    }

    public function getCenterY () :Number
    {
        return _dg.y + _dg.height/2;
    }

    public function getLastDamager () :int
    {
        return 0;
    }

    override public function tick (delta :Number) :void
    {
        super.tick(delta);
        if (_dg.health <= 0 && !_dg.open) {
            _dg.open = true;
        }
    }

    override public function postTick () :void
    {
        _dg.wasHit = false;
        super.postTick();
    }

    protected var _dg :DestructableGate;
}
}
