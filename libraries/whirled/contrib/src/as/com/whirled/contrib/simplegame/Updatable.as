package com.whirled.contrib.simplegame
{
    public interface Updatable
    {
        /** Update this object. dt is the number of seconds that have elapsed since the last update. */
        function update (dt :Number) :void;
    }
}
