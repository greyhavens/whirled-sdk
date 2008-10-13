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

package com.whirled.contrib.simplegame.net {

import com.whirled.game.GameControl;

public class OfflineTickedMessageManager
    implements TickedMessageManager
{
    public function OfflineTickedMessageManager (gameCtrl :GameControl, tickIntervalMS :int)
    {
        _gameCtrl = gameCtrl;

        _randSeed = uint(Math.random() * uint.MAX_VALUE);
        _tickIntervalMS = tickIntervalMS;
        _msTillNextTick = tickIntervalMS;

        // create the first tick
        _ticks.push(new Array());
    }

    public function run () :void
    {
        // no-op
    }

    public function stop () :void
    {
        // no-op
    }

    public function update (dt :Number) :void
    {
        // convert seconds to milliseconds
        _msTillNextTick -= (dt * 1000);
        if (_msTillNextTick <= 0) {
            _ticks.push(new Array());
            _msTillNextTick = _tickIntervalMS;
        }
    }

    public function get isReady () :Boolean
    {
        return true;
    }

    public function get randomSeed () :uint
    {
        return _randSeed;
    }

    public function get unprocessedTickCount () :uint
    {
        return (0 == _ticks.length ? 0 : _ticks.length - 1);
    }

    public function getNextTick () :Array
    {
        if(_ticks.length <= 1) {
            return null;
        } else {
            return (_ticks.shift() as Array);
        }
    }

    public function addMessageFactory (messageName :String, factory :MessageFactory) :void
    {
        // no-op - we never need to serialize or deserialize messages
    }

    public function sendMessage (msg :Message) :void
    {
        // add any actions received during this tick
        var array :Array = (_ticks[_ticks.length - 1] as Array);
        array.push(msg);
    }

    public function canSendMessage () :Boolean
    {
        return true;
    }

    protected var _gameCtrl :GameControl;
    protected var _tickIntervalMS :int;
    protected var _randSeed :uint;
    protected var _ticks :Array = [];
    protected var _msTillNextTick :int;

}
}
