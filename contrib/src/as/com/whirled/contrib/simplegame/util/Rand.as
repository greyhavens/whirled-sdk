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

import com.threerings.util.ArrayUtil;
import com.threerings.util.Random;

public class Rand
{
    public static const STREAM_GAME :uint = 0;
    public static const STREAM_COSMETIC :uint = 1;

    public static function addStream (seed :uint = 0) :uint
    {
        _randStreams.push(new Random(seed));
        return (_randStreams.length - 1);
    }

    public static function getStream (streamId :uint) :Random
    {
        return (_randStreams[streamId] as Random);
    }

    public static function seedStream (streamId :uint, seed :uint) :void
    {
        getStream(streamId).setSeed(seed);
    }

    /** Returns a random element from the given Array. */
    public static function nextElement (arr :Array, streamId :uint) :*
    {
        return (arr.length > 0 ? arr[nextIntRange(0, arr.length, streamId)] : undefined);
    }

    /** Returns an integer in the range [0, MAX) */
    public static function nextInt (streamId :uint) :int
    {
        return getStream(streamId).nextInt();
    }

    /** Returns an int in the range [low, high) */
    public static function nextIntRange (low :int, high :int, streamId :uint) :int
    {
        return low + getStream(streamId).nextInt(high - low);
    }

    public static function nextBoolean (streamId :uint) :Boolean
    {
        return getStream(streamId).nextBoolean();
    }

    public static function nextNumber (streamId :uint) :Number
    {
        return getStream(streamId).nextNumber();
    }

    /** Returns a Number in the range [low, high) */
    public static function nextNumberRange (low :Number, high :Number, streamId :uint) :Number
    {
        return low + (getStream(streamId).nextNumber() * (high - low));
    }

    public static function shuffleArray (arr :Array, streamId :uint) :void
    {
        ArrayUtil.shuffle(arr, getStream(streamId));
    }

    // We always have the STREAM_GAME and STREAM_COSMETIC streams
    protected static var _randStreams :Array = [ new Random(), new Random() ];
}

}
