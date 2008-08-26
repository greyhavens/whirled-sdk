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

package com.whirled.contrib.platformer.board {

import com.whirled.contrib.platformer.util.Maths;

import com.whirled.contrib.platformer.game.ActorController;

import com.whirled.contrib.platformer.piece.Actor;

public class FlyTask extends ColliderTask
{
    public function FlyTask (ac :ActorController, col :Collider)
    {
        super(ac, col);
        _sab = col.getDynamicBounds(ac.getActor()) as SimpleActorBounds;
    }

    public override function init (delta :Number) :void
    {
        super.init(delta);
        _lastDelta = NaN;
    }

    public override function genCD () :ColliderDetails
    {
        if (_cd == null) {
            var a :Actor = _sab.actor;
            a.dy += a.accelY * _delta;
            a.dy -= Maths.sign0(a.dy) * Maths.limit(DRAG * _delta, Math.abs(a.dy));
            var maxDy :Number = (a.health > 0) ? MAX_DY : MAX_DEAD_DY;
            a.dy = Math.min(Math.max(a.dy, -maxDy), maxDy);
            a.dx += a.accelX * _delta;
            a.dx -= Maths.sign0(a.dx) * Maths.limit(DRAG * _delta, Math.abs(a.dx));
            a.dx = Math.min(Math.max(a.dx, -MAX_DX), MAX_DX);
            _cd = _sab.findColliders(_delta, _cd);
        }
        return _cd;
    }

    protected override function runTask () :void
    {
        _sab.move(_cd);
        if (_cd != null) {
            if (!isNaN(_lastDelta)) {
                if (_lastDelta == _cd.rdelta) {
                    _cd.rdelta = 0;
                }
            }
            if (_cd.colliders != null && _cd.colliders.length > 0) {
                _sab.actor.events.push("hit_ground");
            }
            _lastDelta = _delta;
            _delta = _cd.rdelta;
            _cd = null;
        } else {
            _delta = 0;
        }
    }

    protected var _lastDelta :Number;
    protected var _sab :SimpleActorBounds;

    protected var MAX_DY :Number = 1;
    protected var MAX_DEAD_DY :Number = 3;
    protected var MAX_DX :Number = 3;
    protected var DRAG :Number = 0.5;
}
}
