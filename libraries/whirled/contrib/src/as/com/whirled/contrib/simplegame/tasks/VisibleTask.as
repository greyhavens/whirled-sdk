package com.whirled.contrib.simplegame.tasks {

import com.threerings.util.Assert;

import com.whirled.contrib.simplegame.components.VisibleComponent;
import com.whirled.contrib.simplegame.ObjectTask;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.ObjectMessage;

import flash.display.DisplayObject;

public class VisibleTask
    implements ObjectTask
{
    public function VisibleTask (visible :Boolean)
    {
        _visible = visible;
    }

    public function update (dt :Number, obj :SimObject) :Boolean
    {
        var vc :VisibleComponent = (obj as VisibleComponent);
        
        if (null == vc) {
            throw new Error("VisibleTask can only be applied to SimObjects that implement VisibleComponent");
        }

        vc.visible = _visible;

        return true;
    }

    public function clone () :ObjectTask
    {
        return new VisibleTask(_visible);
    }

    public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        return false;
    }

    protected var _visible :Boolean;
}

}
