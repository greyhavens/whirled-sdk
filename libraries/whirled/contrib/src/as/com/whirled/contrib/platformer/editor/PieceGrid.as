//
// $Id$

package com.whirled.contrib.platformer.editor {

import mx.controls.AdvancedDataGrid;

import flash.events.KeyboardEvent;

/**
 * An AdvancedDataGrid that allows you to override the default keypressed handling.
 */
public class PieceGrid extends AdvancedDataGrid
{
    public function PieceGrid ()
    {
        super();
    }

    public function setKeyPressedHandler (keyHandler :Function) :void
    {
        _keyHandler = keyHandler;
    }

    protected override function keyDownHandler (event: KeyboardEvent) :void
    {
        if (_keyHandler != null) {
            if (!_keyHandler(event)) {
                super.keyDownHandler(event);
            }
        } else {
            super.keyDownHandler(event);
        }
    }

    protected var _keyHandler :Function;
}
}
