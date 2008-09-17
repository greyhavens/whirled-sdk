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

import com.whirled.contrib.platformer.util.Maths;

import com.whirled.contrib.platformer.board.ColliderDetails;
import com.whirled.contrib.platformer.board.SimpleActorBounds;
import com.whirled.contrib.platformer.board.LineData;

public class BounceCollisionHandler extends CollisionHandler
{
    public function BounceCollisionHandler (ac :ActorController)
    {
        super(ActorController);
        _ac = ac;
    }

    override public function handlesObject (o :Object) :Boolean
    {
        if (_ac.getActor().health <= 0) {
            return false;
        }
        if (super.handlesObject(o)) {
            if ((o as ActorController).getActor().health > 0 &&
                    _colliders.indexOf(o) == -1) {
                return true;
            }
            trace("ignoring bounce-collided target");
        }
        return false;
    }

    override public function collide (source :Object, target :Object, cd :ColliderDetails) :void
    {
        sabCollide(source as SimpleActorBounds, target as SimpleActorBounds, cd);
    }

    override public function reset () :void
    {
        if (_colliders.length > 0) {
            _colliders = new Array();
        }
    }

    protected function sabCollide (
            source :SimpleActorBounds, target :SimpleActorBounds, cd :ColliderDetails) :void
    {
        var idx :int = cd.acolliders.indexOf(target);
        var crosser :SimpleActorBounds = source;
        if (idx == -1) {
            idx = cd.acolliders.indexOf(source);
            crosser = target;
        }
        var ay :Number = 0;
        var ax :Number = 0;
        var by :Number = 0;
        var bx :Number = 0;
        for each (var col :LineData in cd.alines[idx]) {
            if (crosser.didCross(col, cd.fcdX, cd.fcdY)) {
                ay += col.ny;
                ax += col.nx;
            } else if (col.polyIntersecting(crosser.lines)) {
                by += col.ny;
                bx += col.nx;
            }
        }
        if (ay == 0 && ax == 0) {
            ay = by;
            ax = bx;
        }
        if (source == crosser) {
            ay *= -1;
            ax *= -1;
        }
        if (ay > 0) {
            target.actor.dy = 9.5 * ay;
            source.actor.dy -= 0.5;
        } else if (ay < 0) {
            target.actor.dy = 2 * ay;
            source.actor.dy += 0.5;
        }

        if (Math.abs(ax) > 0) {
            target.actor.dx = 4 * ax;
            source.actor.dx += Maths.sign0(ax) * -0.5;
        }
        trace("bounce collide adjust (" + ax + ", " + ay + "), (" + target.actor.dx + ", " + target.actor.dy + ")");
        if (ay != 0 || ax != 0) {
            target.controller.getTask().reset();
            if (ay > 0) {
                source.actor.events.push("bounce");
            } else {
                source.actor.events.push("hit_sm");
            }
        }
        _colliders.push(target.controller);
    }

    protected var _colliders :Array = new Array();
    protected var _ac :ActorController;
}
}
