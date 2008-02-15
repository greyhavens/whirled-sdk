package com.whirled.contrib.core.tasks {

import com.whirled.contrib.core.SimObject;
import com.whirled.contrib.core.ObjectTask;
import com.whirled.contrib.core.ObjectMessage;

public class TimedTask
    implements ObjectTask
{
    public function TimedTask (time :Number)
    {
        _time = time;
    }

    public function update (dt :Number, obj :SimObject) :Boolean
    {
        _elapsedTime += dt;

        return (_elapsedTime >= _time);
    }

    public function clone () :ObjectTask
    {
        return new TimedTask(_time);
    }

    public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        return false;
    }

    protected var _time :Number = 0;
    protected var _elapsedTime :Number = 0;
}

}
