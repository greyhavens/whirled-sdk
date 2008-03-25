package com.whirled.contrib.simplegame.objects {

import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.tasks.*;

public class SimpleTimer extends SimObject
{
    public function SimpleTimer (delay :Number, callback :Function, repeating :Boolean = false, objectName :String = null)
    {
        _name = objectName;
        _timeLeft["value"] = delay;

        if (repeating) {
            var repeatingTask :RepeatingTask = new RepeatingTask();

            // init _timeLeft to delay
            repeatingTask.addTask(new AnimateValueTask(_timeLeft, delay, 0));

            // animate _timeLeft to 0 over delay seconds
            repeatingTask.addTask(new AnimateValueTask(_timeLeft, 0, delay));

            // call the callback
            repeatingTask.addTask(new FunctionTask(callback));

            this.addTask(repeatingTask);

        } else {
            var serialTask :SerialTask = new SerialTask();

            // decrement _timeLeft to 0 over delay seconds
            serialTask.addTask(new AnimateValueTask({ value: _timeLeft }, 0, delay));

            // call the callback
            serialTask.addTask(new FunctionTask(callback));

            this.addTask(serialTask);
        }
    }

    override public function get objectName () :String
    {
        return _name;
    }

    public function get timeLeft () :Number
    {
        return _timeLeft["value"];
    }

    protected var _name;
    protected var _timeLeft :Object = {};

}

}
