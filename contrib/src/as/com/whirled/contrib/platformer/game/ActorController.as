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

import com.whirled.contrib.platformer.piece.Actor;

import com.whirled.contrib.platformer.board.ColliderTask;

public class ActorController extends DynamicController
    implements ShootableController
{
    public function ActorController (actor :Actor, controller :GameController)
    {
        super(actor, controller);
        _actor = actor;
    }

    public function getActor () :Actor
    {
        return _actor;
    }

    public function doesHit (x :Number = NaN, y :Number = NaN) :Boolean
    {
        return _actor.doesHit(x, y);
    }

    public function doesCollide () :Boolean
    {
        return true;
    }

    public function doHit (damage :Number) :void
    {
        _actor.health -= damage;
    }

    public function getCenterX () :Number
    {
        return _actor.x + _actor.width/2;
    }

    public function getCenterY () :Number
    {
        return _actor.y + _actor.height/2;
    }

    override public function postTick () :void
    {
        super.postTick();
        _actor.wasHit = 0;
        if (_actor.events.length > 0) {
            _actor.events = new Array();
        }
    }

    public function canAttack () :Boolean
    {
        return false;
    }

    public function inAttack (o :Object) :Boolean
    {
        return false;
    }

    public function startAttack () :void
    {
    }

    public function doAttack (target :ActorController, doesHit :Boolean) :void
    {
    }

    protected var _actor :Actor;
}
}
