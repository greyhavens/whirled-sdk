package com.whirled.contrib.core.tasks {

import com.threerings.util.Assert;

import com.whirled.contrib.core.ObjectTask;
import com.whirled.contrib.core.AppObject;
import flash.display.DisplayObject;

public class VisibleTask extends ObjectTask
{
    public function VisibleTask (visible :Boolean)
    {
        _visible = visible;
    }

    override public function update (dt :Number, obj :AppObject) :Boolean
    {
        var displayObj :DisplayObject = obj.displayObject;
        Assert.isNotNull(displayObj, "VisibleTask can only be applied to AppObjects with attached display objects.");

        displayObj.visible = _visible;

        return true;
    }

    override public function clone () :ObjectTask
    {
        return new VisibleTask(_visible);
    }

    protected var _visible :Boolean;
}

}
