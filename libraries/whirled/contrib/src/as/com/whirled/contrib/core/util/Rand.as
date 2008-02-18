package com.whirled.contrib.core.util {

import com.threerings.util.Random;
import com.threerings.util.Assert;

public class Rand
{
    public static const STREAM_GAME :uint = 0;
    public static const STREAM_COSMETIC :uint = 1;

    public static function setup () :void
    {
        if (_hasSetup) {
            return;
        }

        _hasSetup = true;

        _randStreams.push(new Random());    // STREAM_GAME
        _randStreams.push(new Random());    // STREAM_COSMETIC
    }

    public static function addStream (seed :uint = 0) :uint
    {
        _randStreams.push(new Random(seed));
        return (_randStreams.length - 1);
    }

    public static function getStream (streamId :uint) :Random
    {
        Assert.isTrue(_hasSetup);

        return (_randStreams[streamId] as Random);
    }

    public static function seedStream (streamId :uint, seed :uint) :void
    {
        getStream(streamId).setSeed(seed);
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

    protected static var _hasSetup :Boolean = false;
    protected static var _randStreams :Array = new Array();
}

}
