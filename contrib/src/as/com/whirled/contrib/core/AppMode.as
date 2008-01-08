package com.whirled.contrib.core {

import com.threerings.util.Assert;
import com.threerings.util.HashMap;
import com.threerings.util.ArrayUtil;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;

public class AppMode extends ObjectDB
{
    public function AppMode ()
    {
    }

    public function get modeSprite () :Sprite
    {
        return _modeSprite;
    }

    /** Called when the mode is added to the mode stack */
    protected function setup () :void
    {
    }

    /** Called when the mode is removed from the mode stack */
    protected function destroy () :void
    {
    }

    /** Called when the mode becomes active on the mode stack */
    protected function enter () :void
    {
    }

    /** Called when the mode becomes inactive on the mode stack */
    protected function exit () :void
    {
    }

    internal function setupInternal () :void
    {
        setup();
    }

    internal function destroyInternal () :void
    {
        destroy();
    }

    internal function enterInternal () :void
    {
        enter();
    }

    internal function exitInternal () :void
    {
        exit();
    }

    protected var _modeSprite :Sprite = new Sprite();
}

}
