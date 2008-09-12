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
    public function BitmapPool (size :int, width :int, height :int, generator :Function)
    {
        _pool = new Array(size);
        _lookup = new Array();
        _width = width;
        _height = height;
        _generator = generator;
    }

    public function getBitmap (idx :int) :BitmapData
    {
        var cache :PoolCache;
        if (_lookup[idx] == null || _pool[_lookup[idx]].idx != idx) {
            _lookup[idx] = generateBitmap(idx);
        }
        cache = _pool[_lookup[idx]];
        cache.hit = getTimer();
        return cache.bd;
    }

    public function clear () :void
    {
        for (var ii :int = 0, ll :int = _pool.length; ii < ll; ii++) {
            if (_pool[ii] != null) {
                _pool[ii].bd.dispose();
                _pool[ii] = null;
            }
        }
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
        var cache :PoolCache;
        var jj :int;
        for (var ii :int = 0, ll :int = _pool.length; ii < ll; ii++) {
            if (_pool[ii] == null) {
                cache = new PoolCache();
                _pool[ii] = cache;
                jj = ii;
                break;
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
    protected var _width :int;
    protected var _height :int;
}
}

import flash.display.BitmapData;

class PoolCache
{
    public var idx :int;
    public var hit :int;
    public var bd :BitmapData;
}
