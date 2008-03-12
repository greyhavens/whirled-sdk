package com.whirled.contrib.core.tasks {

import com.whirled.contrib.core.ObjectMessage;
import com.whirled.contrib.core.ObjectTask;
import com.whirled.contrib.core.SimObject;

public class FunctionTask
    implements ObjectTask
{
    public function FunctionTask (fn :Function)
    {
        if (null == fn || fn.length > 1) {
            throw new ArgumentError("fn must be non-null, and must accept either 0 or 1 arguments");
        }

        _fn = fn;
    }

    public function update (dt :Number, obj :SimObject) :Boolean
    {
        if (_fn.length == 0) {
            _fn();
        } else {
            _fn(obj);
        }

        return true;
    }

    public function clone () :ObjectTask
    {
        return new FunctionTask(_fn);
    }

    public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        return false;
    }

    protected var _fn :Function;
}

}
