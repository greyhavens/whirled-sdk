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

    public function getTask () :ColliderTask
    {
        return _task;
    }

    public override function postTick () :void
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

    public function inAttack () :Boolean
    {
        return false;
    }

    public function startAttack () :void
    {
    }

    public function doAttack () :void
    {
    }

    protected var _actor :Actor;
    protected var _task :ColliderTask;
}
}
