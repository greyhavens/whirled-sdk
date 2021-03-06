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
import com.whirled.game.OccupantChangedEvent;
import com.whirled.game.StateChangedEvent;

import com.whirled.contrib.persist.PersistenceManager;

import com.whirled.contrib.platformer.board.Board;
import com.whirled.contrib.platformer.game.GameController;
import com.whirled.contrib.platformer.net.MessageManager;
import com.whirled.contrib.platformer.net.DynamicMessage;
import com.whirled.contrib.platformer.net.EventMessage;
import com.whirled.contrib.platformer.net.HoverMessage;
import com.whirled.contrib.platformer.net.ShotMessage;
import com.whirled.contrib.platformer.net.SpawnerMessage;
import com.whirled.contrib.platformer.net.SpawnMessage;
import com.whirled.contrib.platformer.net.TickMessage;
import com.whirled.contrib.platformer.piece.DynamicFactory;
import com.whirled.contrib.platformer.piece.PieceFactory;

public class PlatformerController
{
    public function PlatformerController (disp :DisplayObject)
    {
        PlatformerContext.gctrl = new GameControl(disp, false);
        if (PlatformerContext.gctrl.isConnected()) {
            PlatformerContext.myId = PlatformerContext.gctrl.game.getMyId();
            PlatformerContext.platformer = this;
            PlatformerContext.local =
                    PlatformerContext.gctrl.game.seating.getPlayerIds().length == 1;
            PlatformerContext.net = createMessageManager();
            if (PlatformerContext.net != null) {
                PlatformerContext.net.addMessageType(DynamicMessage);
                PlatformerContext.net.addMessageType(HoverMessage);
                PlatformerContext.net.addMessageType(ShotMessage);
                PlatformerContext.net.addMessageType(SpawnMessage);
                PlatformerContext.net.addMessageType(TickMessage);
                PlatformerContext.net.addMessageType(EventMessage);
                PlatformerContext.net.addMessageType(SpawnerMessage);
            }
            PlatformerContext.persist = createPersistenceManager();
            addOccupantListeners();
        }
    }

    public function shutdown () :void
    {
        PlatformerContext.net.shutdown();
        removeGameListeners();
    }

    public function endGame () :void
    {
    }

    public function startBackgroundMusic (track :String, crossfade :Boolean = true,
        loop :Boolean = true) :void
    {
    }

    protected function run () :void
    {
        PlatformerContext.pfac = createPieceFactory();
        PlatformerContext.dfac = createDynamicFactory();
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

    protected function addOccupantListeners () :void
    {
        PlatformerContext.gctrl.game.addEventListener(
                OccupantChangedEvent.OCCUPANT_LEFT, handleOccupantLeft);
    }

    protected function removeOccupantListeners () :void
    {
        PlatformerContext.gctrl.game.removeEventListener(
                OccupantChangedEvent.OCCUPANT_LEFT, handleOccupantLeft);
    }

    protected function handleOccupantLeft (event :OccupantChangedEvent) :void
    {
    }

    protected function createPieceFactory () :PieceFactory
    {
        return new PieceFactory(null);
    }

    protected function createDynamicFactory () :DynamicFactory
    {
        return new DynamicFactory(null);
    }

    protected function createGameController () :GameController
    {
        throw new Error("createGameController must be implemented in subclass");
    }

    protected function createBoard () :Board
    {
        throw new Error("createBoard must be implemented in subclass");
    }

    protected function createMessageManager () :MessageManager
    {
        return new MessageManager(PlatformerContext.gctrl);
    }

    protected function createPersistenceManager () :PersistenceManager
    {
        return null;
    }
}
}
