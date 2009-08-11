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

package com.whirled.contrib.simplegame.util {

public class WeightedArray
{
    public function WeightedArray (defaultRandStreamId :int)
    {
        _defaultRandStreamId = defaultRandStreamId;
    }

    public function push (data :*, chance :Number) :void
    {
        if (chance <= 0) {
            throw new ArgumentError("chance must be > 0");
        }

        _data.push(new WeightedData(data, chance));
        _dataDirty = true;
    }

    public function getNextData (randStream :int = -1) :*
    {
        updateData();

        if (_data.length == 0) {
            return undefined;
        }

        if (randStream < 0) {
            randStream = _defaultRandStreamId;
        }

        var max :Number = WeightedData(_data[_data.length - 1]).max;
        var val :Number = Rand.nextNumberRange(0, max, _defaultRandStreamId);

        // binary-search the set of WeightedData
        var loIdx :int = 0;
        var hiIdx :int = _data.length - 1;
        for (;;) {
            if (loIdx > hiIdx) {
                // something's broken
                break;
            }

            var idx :int = loIdx + ((hiIdx - loIdx) * 0.5);
            var wd :WeightedData = _data[idx];
            if (val < wd.min) {
                // too high
                hiIdx = idx - 1;
            } else if (val >= wd.max) {
                // too low
                loIdx = idx + 1;
            } else {
                // hit!
                return wd.data;
            }
        }

        // How did we get here?
        return undefined;
    }

    /**
     * Get an array of all of the items that can be returned by this WeightedArray.
     */
    public function getAllData () :Array
    {
        return _data.map(function (wd :WeightedData, ...ignored) :* {
            return wd.data;
        });
    }

    /**
     * The function argument should have the following signature:
     * function (item :*, chance :Number) :void.  It will be called once per item in the array.
     */
    public function forEach (callback :Function) :void
    {
        _data.forEach(function (wd :WeightedData, ...ignored) :void {
            callback(wd.data, wd.chance);
        });
    }

    public function get length () :int
    {
        return _data.length;
    }

    protected function updateData () :void
    {
        if (_dataDirty) {
            var totalVal :Number = 0;
            for each (var wd :WeightedData in _data) {
                wd.min = totalVal;
                totalVal += wd.chance;
            }

            _dataDirty = false;
        }
    }

    protected var _defaultRandStreamId :int;
    protected var _dataDirty :Boolean;

    protected var _data :Array = [];
}

}

class WeightedData
{
    public var data :*;
    public var chance :Number;
    public var min :Number;

    public function get max () :Number
    {
        return min + chance;
    }

    public function WeightedData (data :*, chance :Number)
    {
        this.data = data;
        this.chance = chance;
    }
}
