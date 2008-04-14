package com.whirled.contrib.simplegame.net {

public class OfflineTickedMessageManager
    implements TickedMessageManager
{
    public function OfflineTickedMessageManager (tickIntervalMS :int)
    {
        _randSeed = uint(Math.random() * uint.MAX_VALUE);
        _tickIntervalMS = tickIntervalMS;
        _msTillNextTick = tickIntervalMS;

        // create the first tick
        _ticks.push(new Array());
    }

    public function setup () :void
    {
        // no-op
    }

    public function shutdown () :void
    {
        // no-op
    }

    public function update (dt :Number) :void
    {
        // convert seconds to milliseconds
        var dtMS :int = (dt * 1000);

        // create new tick timeslices as necessary
        while (dtMS > 0) {
            if (dtMS < _msTillNextTick) {
                _msTillNextTick -= dtMS;
                dtMS = 0;
            } else {
                _dtMS -= _msTillNextTick;
                _msTillNextTick = _tickIntervalMS;
                _ticks.push(new Array());
            }
        }
    }

    public function get isReady () :Boolean
    {
        return true;
    }

    public function get randomSeed () :uint
    {
        return _randSeed;
    }

    public function get unprocessedTickCount () :uint
    {
        return (0 == _ticks.length ? 0 : _ticks.length - 1);
    }

    public function getNextTick () :Array
    {
        if(_ticks.length <= 1) {
            return null;
        } else {
            return (_ticks.shift() as Array);
        }
    }

    public function addMessageFactory (messageName :String, factory :MessageFactory) :void
    {
        // no-op - we never need to serialize or deserialize messages
    }

    public function sendMessage (msg :Message) :void
    {
        // add any actions received during this tick
        var array :Array = (_ticks[_ticks.length - 1] as Array);
        array.push(msg);
    }

    public function canSendMessage () :Boolean
    {
        return true;
    }

    protected var _tickIntervalMS :int;
    protected var _randSeed :uint;
    protected var _ticks :Array = [];
    protected var _msTillNextTick :int;

}
}
