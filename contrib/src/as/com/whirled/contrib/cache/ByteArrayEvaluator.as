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
// $Id: SoundController.as 8892 2009-04-09 21:13:55Z nathan $

package com.whirled.contrib.cache {

import flash.utils.ByteArray;

import com.threerings.util.Log;

/**
 * ByteArrays have a known size, and are therefore easy to calculate a sensible value for.  Using
 * this CacheObjectEvaluator on a cache that contains only ByteArrays will result in a
 * memory-usage based cache.
 */
public class ByteArrayEvaluator
    implements CacheObjectEvaluator
{
    public function getValue (obj :Object) :int
    {
        if (!(obj is ByteArray)) {
            log.warning("ByteArrayValue asked to evaluate a non ByteArray", "obj", obj);
            return 1;
        }

        return (obj as ByteArray).length;
    }

    private static const log :Log = Log.getLog(ByteArrayEvaluator);
}
}
