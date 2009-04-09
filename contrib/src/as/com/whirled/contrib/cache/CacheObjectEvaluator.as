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

/**
 * In order to determine whether a given cache is full, the cache must evaluate the value of
 * each item, and compare that total to a configured max value.  This interface provides a method
 * for assigning values to the objects in a cache.  This would typically either be a simple count
 * (each object is worth 1), or a size of the object (each object's value is equal to the number
 * of bytes it consumes).
 */
public interface CacheObjectEvaluator
{
    function getValue (obj :Object) :int;
}
}
