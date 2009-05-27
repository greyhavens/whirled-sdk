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
        _totalChanceCalculated = false;
    }

    public function getNextData () :*
    {
        calculateTotalChance();

        if (_data.length == 0 || _totalChance <= 0) {
            return undefined;
        }

        var rand :Number = Rand.nextNumberRange(0, _totalChance, _defaultRandStreamId);
        var maxValue :Number = 0;
        for each (var wd :WeightedData in _data) {
            maxValue += wd.chance;
            if (rand < maxValue) {
                return wd.data;
            }
        }

        // How did we get here?
        return undefined;
    }

    public function getAllData () :Array
    {
        return _data.map(function (wd :WeightedData, ...ignored) :* {
            return wd.data;
        });
    }

    public function get length () :int
    {
        return _data.length;
    }

    protected function calculateTotalChance () :void
    {
        if (!_totalChanceCalculated) {
            _totalChance = 0;
            for each (var wd :WeightedData in _data) {
                _totalChance += wd.chance;
            }

            _totalChanceCalculated = true;
        }
    }

    protected var _defaultRandStreamId :int;
    protected var _totalChance :Number;
    protected var _totalChanceCalculated :Boolean;

    protected var _data :Array = [];
}

}

class WeightedData
{
    public var data :*;
    public var chance :Number;

    public function WeightedData (data :*, chance :Number)
    {
        this.data = data;
        this.chance = chance;
    }
}
