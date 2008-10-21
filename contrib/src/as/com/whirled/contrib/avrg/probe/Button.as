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

package com.whirled.contrib.avrg.probe {

import flash.text.TextField;
import flash.events.MouseEvent;
import flash.display.Sprite;
import flash.text.TextFieldAutoSize;

[Event("ButtonClick")]

/**
 * Displays some text and dispatches an event when clicked.
 */
public class Button extends Sprite
{
    /**
     * Creates a new button.
     * @param text to display on the button
     * @param action the string to send in the event
     */
    public function Button (text :String = "", action :String = "")
    {
        _text = new TextField();
        _action = action;

        addChild(_text);
        addEventListener(MouseEvent.CLICK, handleMouseClick);

        _text.text = text;
        _text.selectable = false;
        _text.autoSize = TextFieldAutoSize.LEFT;
    }

    public function set text (value:String) :void
    {
        _text.text = value;
    }

    /**
     * The text shown on the button.
     */
    public function get text () :String
    {
        return _text.text;
    }

    /**
     * The action sent by the button when clicked.
     */
    public function get action () :String
    {
        return _action;
    }

    public function set border (value :Boolean) :void
    {
        _text.border = value;
    }

    /**
     * Whether the button has a border drawn around it.
     */
    public function get border () :Boolean
    {
        return _text.border;
    }

    protected function handleMouseClick (event :MouseEvent) :void
    {
        if (event.target == this || event.target == _text) {
            dispatchEvent(new ButtonEvent(ButtonEvent.CLICK, action));
        }
    }

    protected var _text :TextField;
    protected var _action :String;
}

}
