package com.whirled.contrib.core.tasks {

import com.threerings.util.Assert;
import com.whirled.contrib.core.ObjectTask;
import com.whirled.contrib.core.SimObject;
import com.whirled.contrib.core.ObjectMessage;

public class SelfDestructTask
    implements ObjectTask
{
    public function SelfDestructTask ()
    {
    }

    public function update (dt :Number, obj :SimObject) :Boolean
    {
        obj.destroySelf();
        return true;
    }

    public function clone () :ObjectTask
    {
        return new SelfDestructTask();
    }

    public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        return false;
    }
}

}
