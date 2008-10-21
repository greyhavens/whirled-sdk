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

package com.whirled.contrib.platformer.server {

import flash.display.DisplayObject;

import com.whirled.contrib.platformer.PlatformerController;
import com.whirled.contrib.platformer.board.Board;
import com.whirled.contrib.platformer.game.GameController;

public class ServerController extends PlatformerController
{
    public function ServerController (disp :DisplayObject)
    {
        super(disp);
    }

    override protected function createGameController () :GameController
    {
        return new GameController();
    }

    override protected function createBoard () :Board
    {
        return new Board();
    }
}
}
