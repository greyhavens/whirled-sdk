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

package com.whirled.contrib.simplegame.objects {

import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.tasks.*;

public class SimpleTimer extends SimObject
{
    public function SimpleTimer (delay :Number, callback :Function = null, repeating :Boolean = false, objectName :String = null)
    {
        _name = objectName;
        _timeLeft["value"] = delay;

        if (repeating) {
            var repeatingTask :RepeatingTask = new RepeatingTask();

            // init _timeLeft to delay
            repeatingTask.addTask(new AnimateValueTask(_timeLeft, delay, 0));

            // animate _timeLeft to 0 over delay seconds
            repeatingTask.addTask(new AnimateValueTask(_timeLeft, 0, delay));

            if (null != callback) {
                // call the callback
                repeatingTask.addTask(new FunctionTask(callback));
            }

            this.addTask(repeatingTask);

        } else {
            var serialTask :SerialTask = new SerialTask();

            // decrement _timeLeft to 0 over delay seconds
            serialTask.addTask(new AnimateValueTask(_timeLeft, 0, delay));

            if (null != callback) {
                // call the callback
                serialTask.addTask(new FunctionTask(callback));
            }

            // self-destruct when complete
            serialTask.addTask(new SelfDestructTask());

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

    protected var _name :String;
    protected var _timeLeft :Object = {};

}

}
