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
import com.whirled.contrib.platformer.board.LaserShotTask;
import com.whirled.contrib.platformer.piece.LaserShot;

public class LaserShotController extends ShotController
{
    public function LaserShotController (ls :LaserShot, controller :GameController)
    {
        super(ls, controller);
    }

    override protected function createTask () :ColliderTask
    {
        return new LaserShotTask(this, _controller.getCollider());
    }
}
}
