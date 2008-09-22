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
import com.whirled.contrib.platformer.board.SimpleActorBounds;
import com.whirled.contrib.platformer.board.LineData;

public class WalkableCollisionHandler extends CollisionHandler
{
    public function WalkableCollisionHandler (ac :ActorController)
    {
        super(ActorController);
        _ac = ac;
    }

    override public function handlesObject (o :Object) :Boolean
    {
        return _ac.getActor().health > 0 && super.handlesObject(o);
    }

    override public function collide (source :Object, target :Object, cd :ColliderDetails) :void
    {
        sabCollide(source as SimpleActorBounds, target as SimpleActorBounds, cd);
    }

    protected function sabCollide (
        source :SimpleActorBounds, target :SimpleActorBounds, cd :ColliderDetails) :void
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
                    target.actor.dx = 0;
                    stopx = true;
                } else if (col.ny < 0) {
                    stopy = true;
                } else if (col.ny > 0) {
                    attached = col;
                }
            }
        }
        if (!stopx && attached != null) {
            target.actor.attached = attached;
        } else if (stopy && !stopx) {
            target.actor.dy = 0;
        }
    }

    protected var _ac :ActorController;
}
}
