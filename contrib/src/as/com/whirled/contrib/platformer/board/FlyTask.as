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
import com.whirled.contrib.platformer.piece.Dynamic;

public class FlyTask extends ColliderTask
{
    public static function updateVector (
            a :Actor, delta :Number, maxDx :Number, maxDy :Number) :void
    {
        a.dy += a.accelY * delta;
        a.dy -= Maths.sign0(a.dy) * Maths.limit(DRAG * delta, Math.abs(a.dy));
        var maxDy :Number = (a.health > 0) ? maxDy : MAX_DEAD_DY;
        a.dy = Math.min(Math.max(a.dy, -maxDy), maxDy);
        a.dx += a.accelX * delta;
        a.dx -= Maths.sign0(a.dx) * Maths.limit(DRAG * delta, Math.abs(a.dx));
        a.dx = Maths.limit(a.dx, maxDx);
    }

    public function FlyTask (
            ac :ActorController, col :Collider, maxDx :Number = 3, maxDy :Number = 1)
    {
        super(ac, col);
        _sab = col.getDynamicBounds(ac.getActor()) as SimpleActorBounds;
        _maxDx = maxDx;
        _maxDy = maxDy;
    }

    public function get hitX () :Boolean
    {
        return _hitX;
    }

    public function get hitY () :Boolean
    {
        return _hitY;
    }

    override public function init (delta :Number) :void
    {
        _hitX = false;
        _hitY = false;
        super.init(delta);
        _lastDelta = NaN;
    }

    override public function getBounds () :DynamicBounds
    {
        return _sab;
    }

    override public function genCD (ct :ColliderTask = null) :ColliderDetails
    {
        var doReset :Boolean;
        if (_cd == null) {
            updateVector(_sab.actor, _delta, _maxDx, _maxDy);
        } else if (ct != null) {
            if (!_sab.updatedDB(_cd, ct.getBounds())) {
                reset();
            }
            if (!_cd.isValid(_sab.actor)) {
                updateVector(_sab.actor, _delta, _maxDx, _maxDy);
            }
        }
        _cd = _sab.findColliders(_delta, _cd);
        return _cd;
    }

    override protected function runTask () :void
    {
        var a :Actor = _sab.actor;
        _sab.move(_cd);
        _hitX ||= _sab.hitX;
        _hitY ||= _sab.hitY;
        if (_cd != null) {
            if (!isNaN(_lastDelta)) {
                if (_lastDelta == _cd.rdelta) {
                    _cd.rdelta = 0;
                }
            }
            if (!_sab.actor.isAlive() && (_hitX || _hitY)) {
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
    protected var _maxDx :Number;
    protected var _maxDy :Number;
    protected var _hitX :Boolean;
    protected var _hitY :Boolean;

    protected static const MAX_DEAD_DY :Number = 6;
    protected static const DRAG :Number = 0.5;
}
}
