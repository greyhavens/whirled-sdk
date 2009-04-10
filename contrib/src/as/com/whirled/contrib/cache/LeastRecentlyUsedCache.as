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
import flash.utils.Dictionary;
import flash.utils.getTimer; // function import
import flash.utils.Timer;

import com.threerings.util.Log;
import com.threerings.util.MethodQueue;

public class LeastRecentlyUsedCache
    implements Cache
{
    /**
     * @param maxValue This maximum value of the objects in the cache.  If this value is exceeded,
     *                 the oldest values in the cache will be removed.
     * @param evaluator If no evaluator is provided, an ObjectCountEvaluator will be used, causing
     *                  this cache to store maxValue objects before it starts to purge old entries
     * @param evaluationTime The minimum amount of time that must pass between cache evaluations in
     *                       milliseconds.
     */
    public function LeastRecentlyUsedCache (cacheMissSource :DataSource,
        maxValue :int = 1000, evaluator :CacheObjectEvaluator = null, evaluationTime :int = 1000)
    {
        _missSource = cacheMissSource;
        _maxValue = maxValue;
        _evaluator = evaluator == null ? new ObjectCountEvaluator() : evaluator;
        _evaluationTime = evaluationTime;
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
        var idx :int = _cacheNames.indexOf(name);
        var value :Object;
        if (idx >= 0) {
            _stats.cacheHit();
            value = _cacheValues[name];
            if (value == null) {
                log.warning("Cache hit, but found null value", "name", name);
            }
            if (idx != 0) {
                // move this name to the front of the cache
                _cacheNames.splice(idx, 1);
                _cacheNames.unshift(name);
            }
            return value;
        }

        _stats.cacheMiss();
        value = _missSource.getObject(name);
        if (value == null) {
            log.warning("The missSource provided null for an object to cache", "name", name);
        }
        _cacheNames.unshift(name);
        _cacheValues[name] = value;
        // No point in running a cache that doesn't do its best to return values quickly.  We can
        // run the evaluation on the next frame.
        MethodQueue.callLater(evaluateCache);
        return value;
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

        var totalValue :int = 0;
        var toRemove :Array = [];
        for (var ii :int = 0; ii < _cacheNames.length; ii++) {
            totalValue += _evaluator.getValue(_cacheValues[_cacheNames[ii]]);
            if (totalValue > _maxValue) {
                toRemove = _cacheNames.splice(ii);
                break;
            } else if (totalValue == _maxValue && ii < _cacheNames.length - 1) {
                toRemove = _cacheNames.splice(ii + 1);
                break;
            }
            _lastEvaluationTotal = totalValue;
        }
        if (toRemove.length > 0) {
            _stats.cacheDropped(toRemove.length);
            for each (var name :String in toRemove) {
                delete _cacheValues[name];
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
    protected var _cacheNames :Array = [];
    protected var _cacheValues :Dictionary = new Dictionary();
    protected var _stats :CacheStats = new CacheStats();
    protected var _evaluationTime :int;
    protected var _nextEvaluation :int = 0;
    protected var _evaluationTimer :Timer;
    protected var _lastEvaluationTotal :int;
    protected var _timer :Timer;

    private static const log :Log = Log.getLog(LeastRecentlyUsedCache);
}
}
