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

import com.whirled.contrib.platformer.board.ColliderDetails;
import com.whirled.contrib.platformer.board.ActorBounds;
import com.whirled.contrib.platformer.board.DynamicBounds;
import com.whirled.contrib.platformer.board.LineData;

import com.whirled.contrib.platformer.piece.Actor;
import com.whirled.contrib.platformer.piece.Shot;

public class ShotCollisionHandler extends CollisionHandler
{
    public function ShotCollisionHandler ()
    {
        super(ShootableController);
    }

    override public function handlesObject (o :Object) :Boolean
    {
        return super.handlesObject(o) && (o as ShootableController).doesCollide();
    }

    override public function collide (source :Object, target :Object, cd :ColliderDetails) :void
    {
        pCollide(source as Shot, target as DynamicBounds, cd);
    }

    protected function pCollide (s :Shot, db :DynamicBounds, cd :ColliderDetails) :void
    {
        var sc :ShootableController = db.controller as ShootableController;
        var collision :Collision;
        if (cd.alines[0] is LineData) {
            collision = sc.doesHit(cd.alines[0].x1, cd.alines[0].y1);
        } else {
            collision = sc.doesHit();
        }

        if (collision.hits) {
            s.hit = collision;
            sc.doHit(s.damage, s.owner, s.inter, s.owner);
            if (db is ActorBounds) {
                var ab :ActorBounds = db as ActorBounds;
                if (cd.alines[0] is Number) {
                    ab.actor.wasHit = Actor.HIT_FRONT;
                } else if (cd.alines[0] != null && cd.alines[0].nx != 0) {
                    var nx :Number = cd.alines[0].nx;
                    var front :Boolean =
                        (ab.actor.orient & Actor.ORIENT_RIGHT) > 0 ? nx > 0 : nx < 0;
                    ab.actor.wasHit = front ? Actor.HIT_FRONT : Actor.HIT_BACK;
                } else {
                    if (s.dx == 0) {
                        ab.actor.wasHit = Actor.HIT_FRONT;
                    } else if ((s.dx < 0 && (ab.actor.orient & Actor.ORIENT_RIGHT) > 0) ||
                        (s.dx > 0 && (ab.actor.orient & Actor.ORIENT_RIGHT) == 0)) {
                        ab.actor.wasHit = Actor.HIT_FRONT;
                    } else {
                        ab.actor.wasHit = Actor.HIT_BACK;
                    }
                }
                if (s.force != 0) {
                    ab.actor.applyForce(s.dx * s.force / 10, s.dy * s.force / 10);
                    db.controller.getTask().reset();
                }
                if (s.bigHit) {
                    ab.actor.wasHit |= Actor.HIT_BIG;
                }
            }
        } else {
            s.ttl = 0;
            s.miss = collision;
        }
    }
}
}
