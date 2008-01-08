package com.whirled.contrib.core.objects {

import com.whirled.contrib.core.AppObject;
import com.whirled.contrib.core.components.AlphaComponent;
import com.whirled.contrib.core.components.LocationComponent;
import com.whirled.contrib.core.components.ScaleComponent;
import com.whirled.contrib.core.components.SceneComponent;
import com.whirled.contrib.core.components.VisibleComponent;

import flash.display.DisplayObjectContainer;
import flash.display.InteractiveObject;
import flash.display.DisplayObject;

public class SceneObject extends AppObject
    implements AlphaComponent, LocationComponent, ScaleComponent, SceneComponent, VisibleComponent
{
    public function get displayObject () :DisplayObject
    {
        return null;
    }

    public function get displayObjectContainer () :DisplayObjectContainer
    {
        return (this.displayObject as DisplayObjectContainer);
    }

    public function get interactiveObject () :InteractiveObject
    {
        return (this.displayObject as InteractiveObject);
    }

    public function get alpha () :Number
    {
        return this.displayObject.alpha;
    }

    public function set alpha (val :Number) :void
    {
        this.displayObject.alpha = val;
    }

    public function get x () :Number
    {
        return this.displayObject.x;
    }

    public function set x (val :Number) :void
    {
        this.displayObject.x = val;
    }

    public function get y () :Number
    {
        return this.displayObject.y;
    }

    public function set y (val :Number) :void
    {
        this.displayObject.y = val;
    }

    public function get scaleX () :Number
    {
        return this.displayObject.scaleX;
    }

    public function set scaleX (val :Number) :void
    {
        this.displayObject.scaleX = val;
    }

    public function get scaleY () :Number
    {
        return this.displayObject.scaleY;
    }

    public function set scaleY (val :Number) :void
    {
        this.displayObject.scaleY = val;
    }

    public function get visible () :Boolean
    {
        return this.displayObject.visible;
    }

    public function set visible (val :Boolean) :void
    {
        this.displayObject.visible = val;
    }
}

}
