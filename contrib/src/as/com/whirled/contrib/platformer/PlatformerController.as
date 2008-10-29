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

package com.whirled.contrib.platformer {

import flash.display.DisplayObject;

import com.whirled.game.GameControl;
import com.whirled.game.StateChangedEvent;

import com.whirled.contrib.platformer.board.Board;
import com.whirled.contrib.platformer.game.GameController;
import com.whirled.contrib.platformer.piece.PieceFactory;

public class PlatformerController
{
    public function PlatformerController (disp :DisplayObject)
    {
        PlatformerContext.gctrl = new GameControl(disp);
        PlatformerContext.platformer = this;
    }

    public function shutdown () :void
    {
    }

    protected function run () :void
    {
        PlatformerContext.pfac = createPieceFactory();
        addGameListeners();
    }

    protected function addGameListeners () :void
    {
        PlatformerContext.gctrl.game.addEventListener(
                StateChangedEvent.GAME_STARTED, handleGameStarted);
        PlatformerContext.gctrl.game.addEventListener(
                StateChangedEvent.GAME_ENDED, handleGameEnded);
    }

    protected function removeGameListeners () :void
    {
        PlatformerContext.gctrl.game.removeEventListener(
                StateChangedEvent.GAME_STARTED, handleGameStarted);
        PlatformerContext.gctrl.game.removeEventListener(
                StateChangedEvent.GAME_ENDED, handleGameEnded);
    }

    protected function handleGameStarted (...ignored) :void
    {
        PlatformerContext.board = createBoard();
        PlatformerContext.controller = createGameController();
    }

    protected function handleGameEnded (...ignored) :void
    {
    }

    protected function createPieceFactory () :PieceFactory
    {
        return new PieceFactory(null);
    }

    protected function createGameController () :GameController
    {
        throw new Error("createGameController must be implemented in subclass");
    }

    protected function createBoard () :Board
    {
        throw new Error("createBoard must be implemented in subclass");
    }
}
}