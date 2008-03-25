package com.whirled.contrib.simplegame.components {

import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.display.DisplayObjectContainer;

public interface SceneComponent
{
    function get displayObject () :DisplayObject;
    function get displayObjectContainer () :DisplayObjectContainer;
    function get interactiveObject () :InteractiveObject;
}

}
