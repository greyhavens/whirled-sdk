package com.whirled.contrib.simplegame.tasks {

import com.threerings.util.Assert;
import com.whirled.contrib.simplegame.ObjectTask;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.ObjectMessage;

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
