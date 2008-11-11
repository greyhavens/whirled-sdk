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

import flash.events.EventDispatcher;
import flash.events.KeyboardEvent;
import flash.utils.getTimer;

import com.threerings.util.KeyboardCodes;

public class KeyboardController
{
    public function init (ed :EventDispatcher) :void
    {
        if (_ed != ed) {
            if (_ed != null) {
                shutdown();
            }
            _ed = ed;
            if (_ed != null) {
                _ed.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
                _ed.addEventListener(KeyboardEvent.KEY_UP, keyReleased);
            }
        }
    }

    public function shutdown () :void
    {
        _ed.removeEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
        _ed.removeEventListener(KeyboardEvent.KEY_UP, keyReleased);
        _ed = null;
    }

    public function getDx () :Number
    {
        return _dx;
    }

    public function getDy () :Number
    {
        return _dy;
    }

    public function shooting () :Boolean
    {
        return isDown(KeyboardCodes.SHIFT);
    }

    public function jumping () :Boolean
    {
        return isDown(KeyboardCodes.SPACE);
    }

    public function isDown (keyCode :int) :Boolean
    {
        return _downKeys[keyCode] == null ? false : _downKeys[keyCode];
    }

    public function readOnce (keyCode :int) :Boolean
    {
        if (isDown(keyCode) && !_wasRead[keyCode]) {
            _wasRead[keyCode] = true;
            return true;
        }
        return false;
    }

    public function isDoubleTap (keyCode :int) :Boolean
    {
        var now :int = getTimer();
        if (_doubleTap[keyCode] && _lastDown[keyCode] + DOUBLE_TAP > now) {
            return true;
        }
        _doubleTap[keyCode] = false;
        return false;
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
        markPressed(event.keyCode);
        updateACS(event);
    }

    protected function markPressed (keyCode :int) :void
    {
        if (_downKeys[keyCode] == null || _downKeys[keyCode] == false) {
            var now :int = getTimer();
            if (_lastDown[keyCode] != null && _lastDown[keyCode] + DOUBLE_TAP > now) {
                _doubleTap[keyCode] = true;
                //trace("doubleTap: " + keyCode);
            } else {
                _doubleTap[keyCode] = false;
            }
            _lastDown[keyCode] = now;
            _downKeys[keyCode] = true;
            _wasRead[keyCode] = false;
            //trace("keyPressed: " + keyCode);
        }
    }
    protected function updateACS (event :KeyboardEvent) :void
    {
        if (event.shiftKey) {
            markPressed(KeyboardCodes.SHIFT);
        } else {
            _downKeys[KeyboardCodes.SHIFT] = false;
        }
        if (event.altKey) {
            markPressed(KeyboardCodes.ALTERNATE);
        } else {
            _downKeys[KeyboardCodes.ALTERNATE] = false;
        }
        if (event.ctrlKey) {
            markPressed(KeyboardCodes.CONTROL);
        } else {
            _downKeys[KeyboardCodes.CONTROL] = false;
        }
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
        updateACS(event);
        //trace("keyReleased: " + event.keyCode);
    }

    protected var _ed :EventDispatcher;

    protected var _dx :int = 0;
    protected var _dy :int = 0;

    protected var _downKeys :Array = new Array();
    protected var _lastDown :Array = new Array();
    protected var _doubleTap :Array = new Array();
    protected var _wasRead :Array = new Array();

    protected static const DOUBLE_TAP :int = 250;
}
}
