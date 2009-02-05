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

import com.whirled.contrib.platformer.board.ColliderTask;
import com.whirled.contrib.platformer.board.StaticTask;

import com.whirled.contrib.platformer.piece.Dynamic;

import com.threerings.util.ClassUtil;

public class DynamicController
    implements TickController, CollisionController, ShutdownController
{
    public function DynamicController (d :Dynamic, controller :GameController)
    {
        _dynamic = d;
        _controller = controller;
    }

    public function shutdown () :void
    {
    }

    public function hasBounds () :Boolean
    {
        return true;
    }

    public function tick (delta :Number) :void
    {
    }

    public function postTick () :void
    {
    }

    public function getDynamic () :Dynamic
    {
        return _dynamic;
    }

    public function getTask () :ColliderTask
    {
        if (_task == null) {
            _task = createTask();
        }
        return _task;
    }

    public function getCollisionHandler (other :Object) :CollisionHandler
    {
        var ch :CollisionHandler = null;
        for each (var handler :CollisionHandler in _chandlers) {
            if (handler.handlesObject(other)) {
                if (ch == null || handler.handlesSubclass(ch)) {
                    ch = handler;
                }
            }
        }
        return ch;
    }

    public function addCollisionHandler (handler :CollisionHandler) :void
    {
        if (_chandlers == null) {
            _chandlers = new Array();
        }
        _chandlers.push(handler);
    }

    public function postCollider () :void
    {
        for each (var handler :CollisionHandler in _chandlers) {
            handler.reset();
        }
    }

    protected function createTask () :ColliderTask
    {
        return new StaticTask(this, _controller.getCollider());
    }

    protected var _chandlers :Array;
    protected var _dynamic :Dynamic;
    protected var _controller :GameController;
    protected var _task :ColliderTask;
}
}
