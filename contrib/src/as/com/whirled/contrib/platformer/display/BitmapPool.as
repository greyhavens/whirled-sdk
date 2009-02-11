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

package com.whirled.contrib.platformer.display {

import flash.display.BitmapData;
import flash.utils.getTimer;

public class BitmapPool
{
    public function BitmapPool (
            size :int, width :int, height :int, generator :Function, heuristic :Function = null)
    {
        _pool = new Array(size);
        _lookup = new Array();
        _width = width;
        _height = height;
        _generator = generator;
        _heuristic = heuristic;
    }

    public function getBitmap (idx :int) :BitmapData
    {
        var cache :PoolCache;
        _read++;
        if (!inPool(idx)) {
            _lookup[idx] = generateBitmap(idx);
        }
        cache = _pool[_lookup[idx]];
        cache.hit = getTimer();
        return cache.bd;
    }

    public function inPool (idx :int) :Boolean
    {
        return (_lookup[idx] != null && _pool[_lookup[idx]].idx == idx);
    }

    public function ratio () :Number
    {
        return _miss/_read;
    }

    public function clear () :void
    {
        for (var ii :int = 0, ll :int = _pool.length; ii < ll; ii++) {
            if (_pool[ii] != null) {
                _pool[ii].bd.dispose();
                _pool[ii] = null;
            }
        }
        _miss = 0;
        _read = 0;
    }

    public function clearIndex (idx :int) :void
    {
        if (_lookup[idx] != null && _pool[_lookup[idx]].idx == idx) {
            _pool[_lookup[idx]].bd.dispose();
            _pool[_lookup[idx]] = null;
            _lookup[idx] = null;
        }
    }

    /**
     * Generates a bitmap and stores it in the last used cache slot.
     */
    protected function generateBitmap (idx :int) :int
    {
        _miss++;
        var cache :PoolCache;
        var jj :int;
        for (var ii :int = 0, ll :int = _pool.length; ii < ll; ii++) {
            if (_pool[ii] == null) {
                cache = new PoolCache();
                _pool[ii] = cache;
                jj = ii;
                break;
            } else if (_heuristic != null) {
                if (_heuristic(cache, _pool[ii])) {
                    cache = _pool[ii];
                    jj = ii;
                }
            } else if (cache == null || cache.hit > _pool[ii].hit) {
                cache = _pool[ii];
                jj = ii;
            }
        }
        cache.idx = idx;
        if (cache.bd == null) {
            //trace("Adding new bitmap idx: " + idx + " to cache: " + jj);
            cache.bd = new BitmapData(_width, _height, true, 0x00000000);
        } else {
            //trace("Setting bitmap idx: " + idx + " to cache: " + jj);
        }

        _generator(idx, cache.bd);
        return jj;
    }

    protected var _pool :Array;
    protected var _lookup :Array;
    protected var _generator :Function;
    protected var _heuristic :Function;
    protected var _width :int;
    protected var _height :int;
    protected var _miss :int;
    protected var _read :int;
}
}
