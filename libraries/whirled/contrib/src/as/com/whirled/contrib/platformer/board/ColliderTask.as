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

import com.whirled.contrib.platformer.game.CollisionController;

public class ColliderTask
{
    public function ColliderTask (cc :CollisionController, col :Collider)
    {
        _cc = cc;
        _collider = col;
    }

    public function init (delta :Number) :void
    {
        _cd = null;
        _delta = delta;
    }

    public function getCD () :ColliderDetails
    {
        return _cd;
    }

    public function getController () :CollisionController
    {
        return _cc;
    }

    public function genCD () :ColliderDetails
    {
        return _cd;
    }

    public function run () :void
    {
        _running = true;
        runTask();
        _running = false;
    }

    public function isComplete () :Boolean
    {
        return _delta <= 0;
    }

    public function isInteractive () :Boolean
    {
        return true;
    }

    public function reset () :void
    {
        if (!_running) {
            _cd = null;
        }
    }

    public function finish () :void
    {
        _cc.postCollider();
    }

    protected function runTask () :void
    {
    }

    protected var _cc :CollisionController;
    protected var _cd :ColliderDetails;
    protected var _collider :Collider;
    protected var _delta :Number;
    protected var _running :Boolean = false;
}
}
