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

import flash.events.TimerEvent;
import flash.utils.getTimer; // function import
import flash.utils.Timer;

import com.threerings.util.Log;
import com.threerings.util.HashMap;
import com.threerings.util.MethodQueue;

public class LeastFrequentlyUsedCache
    implements Cache
{
    /**
     * @param maxValue This maximum value of the objects in the cache.  If this value is exceeded,
     *                 the least frequently used entries are purged.
     * @param evaluator If no evaluator is provided, an ObjectCountEvaluator will be used, causing
     *                  this cache to store maxValue objects before it starts to purge unused
     *                  entries.
     * @param evaluationTime The minimum amount of time that must pass between cache evaluations in
     *                       milliseconds.
     * @param frequencyThreshold Any accesses older than this amount will not be considered in the
     *                           frequency calculation.
     * @param frequencyCount Only the last frequencyCount accesses will be considered for the
     *                       frequency calculation.
     */
    public function LeastFrequentlyUsedCache (cacheMissSource :DataSource,
        maxValue :int = 1000, evaluator :CacheObjectEvaluator = null, evaluationTime :int = 1000,
        frequencyThreshold :int = 60000, frequencyCount :int = 5)
    {
        _missSource = cacheMissSource;
        _maxValue = maxValue;
        _evaluator = evaluator == null ? new ObjectCountEvaluator() : evaluator;
        _evaluationTime = evaluationTime;
        _frequencyThreshold = frequencyThreshold;
        _frequencyCount = frequencyCount;
    }

    // from Cache
    public function get cacheStats () :CacheStats
    {
        var stats :CacheStats = _stats;
        stats.fixTime();
        stats.setTotalValue(_lastEvaluationTotal);
        _stats = new CacheStats();
        return stats;
    }

    // from DataSource
    public function getObject (name :String) :Object
    {
        var value :FrequentObject = _cacheValues.get(name);
        if (value != null) {
            _stats.cacheHit();

        } else {
            _stats.cacheMiss();
            value = new FrequentObject(
                name, _missSource.getObject(name), _frequencyThreshold, _frequencyCount);
            _cacheValues.put(name, value);
            MethodQueue.callLater(evaluateCache);
        }

        value.requested();
        return value.value;
    }

    protected function evaluateCache () :void
    {
        var now :int = getTimer();
        if (now < _nextEvaluation) {
            if (_timer != null) {
                // we already have an evaluation scheduled
                return;
            }

            _timer = new Timer(_nextEvaluation - now, 1);
            _timer.addEventListener(TimerEvent.TIMER_COMPLETE, timeout);
            _timer.start();
        }

        var values :Array = _cacheValues.values();
        for each (var freqObj :FrequentObject in values) {
            // So that the frequency isn't being constantly recalculated while the array is being
            // sorted (as would happen if the frequency calculation were being done in the frequency
            // getter), we iterate over the list and tell each obj to caculate its frequency first
            freqObj.calculateFrequency();
        }
        values.sortOn("frequency", Array.DESCENDING | Array.NUMERIC);

        var totalValue :int = 0;
        var toRemove :Array = [];
        for (var ii :int = 0; ii < values.length; ii++) {
            totalValue += _evaluator.getValue(values[ii].value);
            if (totalValue > _maxValue) {
                toRemove = values.splice(ii);
                break;
            }
            // This value is copied down every time instead of outside of the loop so that when we
            // break out, it has already been set to the correct value.
            _lastEvaluationTotal = totalValue;
        }
        if (toRemove.length > 0) {
            _stats.cacheDropped(toRemove.length);
            for each (var value :FrequentObject in toRemove) {
                _cacheValues.remove(value.name);
            }
        }

        _nextEvaluation = now + _evaluationTime;
    }

    protected function timeout (event :TimerEvent) :void
    {
        event.target.removeEventListener(TimerEvent.TIMER_COMPLETE, timeout);
        _timer = null;
        evaluateCache();
    }

    protected var _missSource :DataSource;
    protected var _maxValue :int;
    protected var _evaluator :CacheObjectEvaluator;
    protected var _cacheValues :HashMap = new HashMap();
    protected var _stats :CacheStats = new CacheStats();
    protected var _evaluationTime :int;
    protected var _nextEvaluation :int = 0;
    protected var _evaluationTimer :Timer;
    protected var _lastEvaluationTotal :int;
    protected var _timer :Timer;
    protected var _frequencyThreshold :int;
    protected var _frequencyCount :int;

    private static const log :Log = Log.getLog(LeastRecentlyUsedCache);
}
}

import flash.utils.getTimer;

class FrequentObject
{
    public function FrequentObject (name :String, value :Object, threshold :int,
        maxTimes :int) :void
    {
        _name = name;
        _value = value;
        _threshold = threshold;
        _maxTimes = maxTimes;
    }

    public function get frequency () :int
    {
        return _frequency;
    }

    public function get name () :String
    {
        return _name;
    }

    public function get value () :Object
    {
        return _value;
    }

    public function calculateFrequency () :void
    {
        var threshold :int = getTimer() - _threshold;
        _frequency = 0;
        _times.length = Math.min(_maxTimes, _times.length);
        for (var ii :int = 0; ii < _times.length; ii++) {
            if (_times[ii] < threshold) {
                _times.length = ii;
                break;
            }
            _frequency += _times[ii];
        }
    }

    public function requested () :void
    {
        _times.unshift(getTimer());
    }

    protected var _times :Array = [];
    protected var _value :Object;
    protected var _name :String;
    protected var _frequency :int;
    protected var _threshold :int;
    protected var _maxTimes :int;
}
