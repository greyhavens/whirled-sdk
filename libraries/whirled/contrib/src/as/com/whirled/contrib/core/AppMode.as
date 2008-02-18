package com.whirled.contrib.core {

import flash.display.Sprite;

public class AppMode extends ObjectDB
{
    public function AppMode ()
    {
        this.modeSprite.mouseEnabled = false;
        this.modeSprite.mouseChildren = false;
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
        _hasSetup = true;
    }

    internal function destroyInternal () :void
    {
        destroy();
    }

    internal function enterInternal () :void
    {
        this.modeSprite.mouseEnabled = true;
        this.modeSprite.mouseChildren = true;

        enter();
    }

    internal function exitInternal () :void
    {
        this.modeSprite.mouseEnabled = false;
        this.modeSprite.mouseChildren = false;

        exit();
    }

    protected var _modeSprite :Sprite = new Sprite();
    
    internal var _hasSetup :Boolean;
}

}
