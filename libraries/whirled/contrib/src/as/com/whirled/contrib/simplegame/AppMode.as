// Whirled contrib library - tools for developing whirled games
// http://www.whirled.com/code/contrib/asdocs
//
// This library is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library.  If not, see <http://www.gnu.org/licenses/>.
//
// Copyright 2008 Three Rings Design
//
// $Id$

package com.whirled.contrib.simplegame {

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
