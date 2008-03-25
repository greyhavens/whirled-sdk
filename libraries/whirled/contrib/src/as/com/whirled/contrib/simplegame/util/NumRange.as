package com.whirled.contrib.simplegame.util {

public class NumRange
{
    public var min :Number;
    public var max :Number;
    public var defaultRandStreamId :uint;

    public function NumRange (min :Number, max :Number, defaultRandStreamId :uint)
    {
        this.min = min;
        this.max = max;
        this.defaultRandStreamId = defaultRandStreamId;
    }

    public function next (randStreamId :int = -1) :Number
    {
        return Rand.nextNumberRange(this.min, this.max, (randStreamId >= 0 ? randStreamId : defaultRandStreamId));
    }
}

}
