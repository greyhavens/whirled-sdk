package com.whirled.contrib.simplegame.objects {

import flash.display.DisplayObject;

/**
 * This is just a convenience class that extends SceneObject to manage a displayObject directly.
 */
public class SimpleSceneObject extends SceneObject
{
    public function SimpleSceneObject (displayObject :DisplayObject = null)
    {
        _displayObject = displayObject;
    }

    override public function get displayObject () :DisplayObject
    {
        return _displayObject;
    }

    public function set displayObject (displayObject :DisplayObject) :void
    {
        _displayObject = displayObject;
    }

    protected var _displayObject :DisplayObject;

}

}
