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

import flash.events.Event;
import flash.events.KeyboardEvent;

import com.threerings.util.KeyboardCodes;

import com.whirled.game.GameControl;
import com.whirled.contrib.platformer.display.BoardSprite;

public class Controller
{
    public function Controller (gameCtrl :GameControl)
    {
        _gameCtrl = gameCtrl;
    }

    public function getDx () :Number
    {
        return _dx;
    }

    public function getDy () :Number
    {
        return _dy;
    }

    public function getSprite () :BoardSprite
    {
        return _boardSprite;
    }

    public function isDown (keyCode :int) :Boolean
    {
        return _downKeys[keyCode] == null ? false : _downKeys[keyCode];
    }

    protected function keyPressed (event :KeyboardEvent) :void
    {
        if (event.keyCode == KeyboardCodes.UP || event.keyCode == KeyboardCodes.W) {
            _dy = 1;
        } else if (event.keyCode == KeyboardCodes.DOWN || event.keyCode == KeyboardCodes.S) {
            _dy = -1;
        } else if (event.keyCode == KeyboardCodes.LEFT || event.keyCode == KeyboardCodes.A) {
            _dx = -1;
        } else if (event.keyCode == KeyboardCodes.RIGHT || event.keyCode == KeyboardCodes.D) {
            _dx = 1;
        }
        _downKeys[event.keyCode] = true;
    }

    protected function keyReleased (event :KeyboardEvent) :void
    {
        if (event.keyCode == KeyboardCodes.UP || event.keyCode == KeyboardCodes.W) {
            if (_dy == 1) {
                _dy = 0;
            }
        } else if (event.keyCode == KeyboardCodes.DOWN || event.keyCode == KeyboardCodes.S) {
            if (_dy == -1) {
                _dy = 0;
            }
        } else if (event.keyCode == KeyboardCodes.LEFT || event.keyCode == KeyboardCodes.A) {
            if (_dx == -1) {
                _dx = 0;
            }
        } else if (event.keyCode == KeyboardCodes.RIGHT || event.keyCode == KeyboardCodes.D) {
            if (_dx == 1) {
                _dx = 0;
            }
        }
        _downKeys[event.keyCode] = false;
    }

    protected var _dx :int = 0;
    protected var _dy :int = 0;

    protected var _downKeys :Array = new Array();

    protected var _gameCtrl :GameControl;

    protected var _boardSprite :BoardSprite;
}
}
