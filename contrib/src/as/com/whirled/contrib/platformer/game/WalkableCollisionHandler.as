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
import com.whirled.contrib.platformer.board.DynamicBounds;
import com.whirled.contrib.platformer.board.SimpleActorBounds;
import com.whirled.contrib.platformer.board.LineData;
import com.whirled.contrib.platformer.piece.Actor;

public class WalkableCollisionHandler extends CollisionHandler
{
    public function WalkableCollisionHandler (wc :WalkableController)
    {
        super(ActorController);
        _wc = wc;
    }

    override public function handlesObject (o :Object) :Boolean
    {
        return _wc.isWalkable() && super.handlesObject(o);
    }

    override public function collide (source :Object, target :Object, cd :ColliderDetails) :void
    {
        sabCollide(source as DynamicBounds, target as SimpleActorBounds, cd);
    }

    protected function sabCollide (
        source :DynamicBounds, target :SimpleActorBounds, cd :ColliderDetails) :void
    {
        var idx :int = cd.acolliders.indexOf(source);
        var attached :LineData;
        var stopy :Boolean;
        var stopx :Boolean;
        for each (var col :LineData in cd.alines[idx]) {
            if (col == null) {
                continue;
            }
            if (target.didCross(col, cd.fcdX, cd.fcdY)) {
                if (col.nx != 0) {
                    stopx = true;
                } else if (col.ny < 0) {
                    stopy = true;
                } else if (col.ny > 0) {
                    attached = col;
                }
            }
        }
        if (stopx) {
            if (target.actor.attachedId == source.dyn.id) {
                stopx = false;
            } else {
                target.actor.dx = 0;
            }
        }
        if (!stopx && attached != null) {
            if (target.actor.maxAttachable != -1) {
                setAttached(target.actor, attached, source.dyn.id);
            } else {
                target.actor.dx = 0;
            }
        } else if (!stopx && stopy) {
            target.actor.dy = 0;
        }
    }

    protected function setAttached (actor :Actor, line :LineData, id :int) :void
    {
        actor.setAttached(line, id);
    }

    protected var _wc :WalkableController;
}
}
