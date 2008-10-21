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

package com.whirled.contrib.platformer.client {

import com.whirled.contrib.platformer.game.CutSceneController;
import com.whirled.contrib.platformer.game.GameController;
import com.whirled.contrib.platformer.piece.CutScene;

public class ClientCutSceneController extends CutSceneController
{
    public function ClientCutSceneController (cs :CutScene, controller :GameController)
    {
        super(cs, controller);
    }

    override public function tick (delta :Number) :void
    {
        super.tick(delta);
        if (!_cs.played || _cs.stage == _cs.stageChanges.length + 1) {
            if (_ignoreKeys) {
                _ignoreKeys = ClientPlatformerContext.keyboard.shooting() ||
                        ClientPlatformerContext.keyboard.jumping();
            } else if (_cs.hovered && ClientPlatformerContext.keyboard.shooting()) {
                _cs.stage = 0;
                _tick = 0;
            } else if (_controller.isPaused()) {
                _controller.setPause(false);
            }
            return;
        }
        _controller.setPause(true);
        if (_cs.stage == 0) {
            _cs.stage = 1;
            _ignoreKeys = ClientPlatformerContext.keyboard.shooting() ||
                    ClientPlatformerContext.keyboard.jumping();
        } else {
            _tick += delta;
        }
        while (_stageChanges[_cs.stage - 1] < _tick) {
            _cs.stage++;
        }
        if (_ignoreKeys) {
            _ignoreKeys = ClientPlatformerContext.keyboard.shooting() ||
                    ClientPlatformerContext.keyboard.jumping();
        } else if (_keyReset > 0) {
            _keyReset -= delta;
        } else if (ClientPlatformerContext.keyboard.jumping()) {
            _cs.stage = _cs.stageChanges.length + 1;
        } else if (ClientPlatformerContext.keyboard.shooting()) {
            _tick = _stageChanges[_cs.stage - 1];
            _cs.stage++;
            _keyReset = KEY_RESET;
        }
        if (_cs.stage == _cs.stageChanges.length + 1) {
            _ignoreKeys = ClientPlatformerContext.keyboard.shooting() ||
                    ClientPlatformerContext.keyboard.jumping();
        }
    }

    override public function postTick () :void
    {
        super.postTick();
        if (_cs.played && _cs.stage < _cs.stageChanges.length + 1) {
            ClientPlatformerContext.boardSprite.ensureCentered(_cs);
        }
    }
}
}
