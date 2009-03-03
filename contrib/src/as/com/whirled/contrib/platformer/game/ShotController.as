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
import com.whirled.contrib.platformer.board.ShotTask;

import com.whirled.contrib.platformer.piece.Shot;

public class ShotController extends DynamicController
{
    public function ShotController (pro :Shot, controller :GameController)
    {
        super(pro, controller);
        _shot = pro;
        createCollisionHandlers();
    }

    public function getShot () :Shot
    {
        return _shot;
    }

    override public function tick (delta :Number) :void
    {
        _shot.ttl -= delta;
    }

    override public function postTick () :void
    {
        if (_shot.hit != null || _shot.ttl <= 0) {
            _controller.removeDynamic(_shot);
        }
    }

    override protected function createTask () :ColliderTask
    {
        return new ShotTask(this, _controller.getCollider());
    }

    protected function createCollisionHandlers () :void
    {
        addCollisionHandler(new ShotCollisionHandler());
    }

    protected var _shot :Shot;
}
}
