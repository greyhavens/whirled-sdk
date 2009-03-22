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

import com.whirled.contrib.platformer.PlatformerContext;
import com.whirled.contrib.platformer.piece.Actor;
import com.whirled.contrib.platformer.piece.Attachable;
import com.whirled.contrib.platformer.piece.Dynamic;
import com.whirled.contrib.platformer.util.Maths;

import com.whirled.contrib.platformer.game.ActorController;

public class WalkTask extends ColliderTask
{
    public function WalkTask (ac :ActorController, col :Collider)
    {
        super(ac, col);
        _sab = col.getDynamicBounds(ac.getActor()) as SimpleActorBounds;
    }

    public function get hitX () :Boolean
    {
        return _hitX;
    }

    public function get hitY () :Boolean
    {
        return _hitY;
    }

    public function setMaxDx (dx :Number) :void
    {
        _maxDx = dx;
    }

    override public function init (delta :Number) :void
    {
        _hitX = false;
        _hitY = false;
        super.init(delta);
        if (PlatformerContext.gctrl.game.amServerAgent()) {
            return;
        }
        var a :Actor = _sab.actor;
        if (a.attachedId != -1) {
            var d :Dynamic = PlatformerContext.board.getDynamic(a.attachedId);
            if (d == null) {
                d = PlatformerContext.board.getActor(a.attachedId);
            }
            if (d == null || !(d is Attachable) || !(d as Attachable).isAttachable()) {
                a.setAttached(null);
            }
        }
        if (a.attached == null || a.accelY > 0) {
            var xdrag :Number = 9;
            var ydrag :Number = 15;
            if (!a.isAlive()) {
               xdrag = 3;
               ydrag = 20;
            }
            a.dy += a.accelY * delta;
            a.dy -= ydrag * delta;
            a.dy = Math.max(a.dy, -Collider.MAX_DY);
            a.dx += a.accelX * delta;
            a.dx -= Maths.sign0(a.dx) * Maths.limit(xdrag * delta, Math.abs(a.dx));
            a.dx = Maths.limit(a.dx, _maxDx);
        }
        _attached = null;
        _new = false;
        _lastDelta = NaN;
        updateVector();
    }

    override public function getBounds () :DynamicBounds
    {
        return _sab;
    }

    override public function genCD (ct :ColliderTask = null) :ColliderDetails
    {
        if (_cd != null) {
            if ((ct != null && _sab.updatedDB(_cd, ct.getBounds())) || !_cd.isValid(_sab.actor)) {
                reset();
            }
        }
        _cd = _sab.findColliders(_delta, _cd);
        return _cd;
    }

    override public function reset () :void
    {
        super.reset();
        if (!_running) {
            updateVector();
        }
    }

    protected function updateVector () :void
    {
        if (PlatformerContext.gctrl.game.amServerAgent()) {
            return;
        }
        var a :Actor = _sab.actor;

        if (a.attached != null && a.attached != _attached && a.accelY <= 0) {
            _attached = a.attached;
            // Newly attached to a walkable tile, preserve our momentum
            if (Math.abs(a.attached.iy) < a.maxWalkable) {
                var dot :Number = a.attached.dot(a.dx, a.dy);
                //var dot :Number = a.dx * a.attached.ix + a.dy * a.attached.iy;
                if (a.attached.ix >= 0) {
                    dot += a.accelX * _delta;
                } else {
                    dot -= a.accelX * _delta;
                }
                dot -= Maths.sign0(dot) * Maths.limit(9 * _delta, Math.abs(dot));
                dot = Maths.limit(dot, _maxDx);
                a.dx = dot * a.attached.ix;
                a.dy = dot * a.attached.iy;

            // Newly attached to an unwalkable tile, start to slide
            } else {
                if (a.attached.iy > 0) {
                    a.dx = - a.attached.ix;
                    a.dy = - a.attached.iy;
                } else {
                    a.dx = a.attached.ix;
                    a.dy = a.attached.iy;
                }
                a.dx *= 6;
                a.dy *= 6;
                a.dx = Maths.limit(a.dx, _maxDx);
                a.dy = Maths.limit(a.dy, Collider.MAX_DY);
            }
            _new = true;
        }
        if (a.attached != null) {
            adjustAttached(a);
        }
    }

    protected function adjustAttached (a :Actor) :void
    {
        if (a.accelY == 0 && a.attached.mag > 0.2 &&
            ((a.attached.isLineOutside(_sab.getBottomLine()) &&
                a.attached.normalDot(a.dx, a.dy) < 0) ||
            (a.attached.isLineInside(_sab.getBottomLine()) &&
                a.attached.normalDot(a.dx, a.dy) > 0))) {
            var mag :Number = a.attached.dot(a.dx, a.dy);
            a.dx = a.attached.ix * mag;
            a.dy = a.attached.iy * mag;
        }
        if (a.attached.isIntersecting(_sab.getBottomLine()) ||
                (a.attached.iy == 0 && a.attached.y1 >= _sab.getBottomLine().y1)) {
            a.dy += 1;
            //trace(a.sprite + "(" + a.id + ") is intersecting attached " + a.attached +
            //        ", " + _sab.getBottomLine());
        }
    }

    override protected function runTask () :void
    {
        _sab.move(_cd);
        _hitX ||= _sab.hitX;
        _hitY ||= _sab.hitY;
        if (_sab.actor.accelY > 0) {
            _sab.actor.setAttached(null);
        }
        if (_cd != null) {
            if (!isNaN(_lastDelta)) {
                if (_lastDelta == _cd.rdelta) {
                    _cd.rdelta = 0;
                }
            }
            _lastDelta = _delta;
            _delta = _cd.rdelta;
        } else {
            _delta = 0;
            trace("WalkTask ran with no cd");
        }
    }

    protected var _attached :LineData;
    protected var _lastDelta :Number;
    protected var _sab :SimpleActorBounds;
    protected var _maxDx :Number = Collider.MAX_DX;
    protected var _hitX :Boolean;
    protected var _hitY :Boolean;
    protected var _new :Boolean;
}
}
