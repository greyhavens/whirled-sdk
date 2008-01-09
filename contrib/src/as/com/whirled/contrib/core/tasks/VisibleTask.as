package com.whirled.contrib.core.tasks {

import com.threerings.util.Assert;

import com.whirled.contrib.core.components.VisibleComponent;
import com.whirled.contrib.core.ObjectTask;
import com.whirled.contrib.core.AppObject;
import com.whirled.contrib.core.ObjectMessage;

import flash.display.DisplayObject;

public class VisibleTask
    implements ObjectTask
{
    public function VisibleTask (visible :Boolean)
    {
        _visible = visible;
    }

    public function update (dt :Number, obj :AppObject) :Boolean
    {
        var vc :VisibleComponent = (obj as VisibleComponent);
        Assert.isNotNull(vc, "VisibleTask can only be applied to AppObjects that implement VisibleComponent.");

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
