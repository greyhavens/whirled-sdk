package com.whirled.contrib.core.tasks {

import com.threerings.util.Assert;
import com.whirled.contrib.core.ObjectTask;
import com.whirled.contrib.core.AppObject;
import com.whirled.contrib.core.ObjectMessage;

public class FunctionTask
    implements ObjectTask
{
    public function FunctionTask (fn :Function)
    {
        Assert.isNotNull(fn);
        Assert.isTrue(fn.length == 0 || fn.length == 1);
        _fn = fn;
    }

    public function update (dt :Number, obj :AppObject) :Boolean
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
