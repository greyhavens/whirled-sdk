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

import com.whirled.contrib.platformer.piece.CutScene;

public class CutSceneController extends HoverController
    implements PauseController
{
    public function CutSceneController (cs :CutScene, controller :GameController)
    {
        super(cs, controller);
        _cs = cs;
        var tot :Number = 0;
        for each (var len :Number in _cs.stageChanges) {
            tot += len;
            _stageChanges.push(tot);
        }
    }

    override public function tick (delta :Number) :void
    {
        super.tick(delta);
        if (!_cs.played || _cs.stage == _cs.stageChanges.length + 1) {
            if (_ignoreKeys) {
                _ignoreKeys = _controller.shooting() || _controller.jumping();
            } else if (_cs.hovered && _controller.shooting()) {
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
            _ignoreKeys = _controller.shooting() || _controller.jumping();
        } else {
            _tick += delta;
        }
        while (_stageChanges[_cs.stage - 1] < _tick) {
            _cs.stage++;
        }
        if (_ignoreKeys) {
            _ignoreKeys = _controller.shooting() || _controller.jumping();
        } else if (_keyReset > 0) {
            _keyReset -= delta;
        } else if (_controller.jumping()) {
            _cs.stage = _cs.stageChanges.length + 1;
        } else if (_controller.shooting()) {
            _tick = _stageChanges[_cs.stage - 1];
            _cs.stage++;
            _keyReset = KEY_RESET;
        }
        if (_cs.stage == _cs.stageChanges.length + 1) {
            _ignoreKeys = _controller.shooting() || _controller.jumping();
        }
    }

    override public function postTick () :void
    {
        super.postTick();
        if (_cs.played && _cs.stage < _cs.stageChanges.length + 1) {
            _controller.ensureCentered(_cs);
        }
    }

    override protected function addCollisionHandlers () :void
    {
        addCollisionHandler(new CutSceneCollisionHandler(this));
    }

    protected var _cs :CutScene;
    protected var _tick :Number = 0;
    protected var _keyReset :Number = 0;
    protected var _ignoreKeys :Boolean;
    protected var _stageChanges :Array = new Array();
    protected static const KEY_RESET :Number = 0.3;
}
}
