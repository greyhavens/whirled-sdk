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

package com.whirled.contrib.cache {

import flash.utils.getTimer;

public class CacheStats
{
    public function get hits () :int
    {
        return _hits;
    }

    public function get misses () :int
    {
        return _misses;
    }

    public function get timeElapsed () :int
    {
        return _totalTime;
    }

    public function get totalValue () :int
    {
        return _totalValue;
    }

    public function get dropped () :int
    {
        return _dropped;
    }

    public function cacheHit () :void
    {
        _hits++;
    }

    public function cacheMiss () :void
    {
        _misses++;
    }

    public function cacheDropped (value :int) :void
    {
        _dropped += value;
    }

    public function fixTime () :void
    {
        _totalTime = getTimer() - _statsCreation;
    }

    public function setTotalValue (value :int) :void
    {
        _totalValue = value;
    }

    public function toString () :String
    {
        return "CacheStats [hits=" + hits + ", misses=" + misses + ", dropped=" + dropped +
            ", time(ms)=" + timeElapsed + ", value=" + totalValue + "]";
    }

    protected var _hits :int = 0;
    protected var _misses :int = 0;
    protected var _timeElapsed :int = 0;
    protected var _statsCreation :int = getTimer();
    protected var _totalTime :int = 0;
    protected var _totalValue :int = 0;
    protected var _dropped :int = 0;
}
}
