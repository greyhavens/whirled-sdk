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

import com.whirled.contrib.platformer.piece.Actor;

public class AttackCollisionHandler extends CollisionHandler
{
    public function AttackCollisionHandler (ac :ActorController)
    {
        super(ActorController);
        _ac = ac;
    }

    override public function handlesObject (o :Object) :Boolean
    {
        return (_ac.canAttack() || _ac.inAttack()) && super.handlesObject(o) &&
            ((o as ActorController).getActor().health > 0);
    }

    override public function collide (source :Object, target :Object, cd :ColliderDetails) :void
    {
        var sab :ActorBounds = source as ActorBounds;
        var ac :ActorController = sab.controller as ActorController;
        var tab :ActorBounds = target as ActorBounds;
        if (_ac.canAttack()) {
            ac.startAttack();
        } else {
            var hit :Boolean = false;
            if (tab.actor.doesHit(tab.actor.x, tab.actor.y)) {
                var diff :Number =
                        tab.actor.x + tab.actor.width/2 - sab.actor.x - sab.actor.width/2;
                tab.actor.wasHit = ((diff > 0 && (tab.actor.orient & Actor.ORIENT_RIGHT) == 0) ||
                        (diff < 0 && (tab.actor.orient & Actor.ORIENT_RIGHT) > 0)) ?
                    Actor.HIT_FRONT : Actor.HIT_BACK;
                hit = true;
            }
            ac.doAttack(tab.controller as ActorController, hit);
        }
    }

    protected var _ac :ActorController;
}
}
