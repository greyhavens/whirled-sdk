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

package com.whirled.contrib {

import flash.display.DisplayObject;
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.filters.DropShadowFilter;

import flash.events.MouseEvent;

import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;

import flash.utils.setTimeout;

import com.threerings.ui.SimpleTextButton;
import com.threerings.util.Log;

import com.whirled.EntityControl;

/**
 * Entites that need initial configuration, e.g. after purchase from the catalog, may
 * find this class useful. It looks up a configuration entry by key in the entity's
 * memory, and if it does not find the entry, waits for a mouse click on the entity's
 * sprite.
 *
 * The click pops up a configuration pane which asks for the value, which is then set
 * in entity memory so nobody ever sees the popup again.
 */
public class Configurator
{
    /**
     * Gets the requested configuration entry from entity memory or failing that, from
     * the user; whenever the value (which is a String) is safely in hand, the callback
     * is executed with it, and the entity may continue setting itself up.
     */
    public static function requestEntry (control :EntityControl, sprite :DisplayObject,
                                         key :String, configured :Function) :void
    {
        new Configurator(control, sprite, key, configured);
    }

    public function Configurator (control :EntityControl, sprite :DisplayObject,
                                  key :String, configured :Function)
    {
        // most of the time the value will have been configured
        var value :Object = control.getMemory(key);
        if (value != null) {
            setTimeout(configured, 0, value);
            return;
        }
        // otherwise remember all the bits
        _control = control;
        _key = key;
        _configured = configured;

        // and wait for a click
        sprite.addEventListener(MouseEvent.CLICK, handleClick);
    }

    protected function handleClick (evt :MouseEvent) :void
    {
        // the base of the GUI is a Sprite
        var popup :Sprite = new Sprite();

        var y :int = PADDING;

        var format :TextFormat = new TextFormat();
        format.font = "Arial";
        format.size = 14;
        format.color = 0xFFFFFF;

        // it has a descriptive text field
        var text :TextField = new TextField();
        text.x = PADDING;
        text.y = y;
        text.defaultTextFormat = format;
        text.width = WIDTH - PADDING;
        text.autoSize = TextFieldAutoSize.LEFT;
        text.wordWrap = true;
        text.htmlText =
            "Please enter a value for this object's <i>" + _key + "</i> configuration entry:";
        popup.addChild(text);

        y += text.height + PADDING;

        // an input field
        var input :TextField = new TextField();
        input.x = 2 * PADDING;
        input.y = y;
        input.defaultTextFormat = format;
        input.width = WIDTH - 4 * PADDING;
        input.height = 18;
        input.maxChars = 16; // arbitrary
        input.type = TextFieldType.INPUT;

        // and a decoratively rounded widget
        var inputBox :Shape = new Shape();
        inputBox.x = input.x - 2;
        inputBox.y = input.y - 2;
        with (inputBox.graphics) {
            beginFill(0x6699CC);
            drawRoundRect(0, 0, input.width + 4, input.height + 4, 10);
            endFill();
        }
        // be sure to add the background widget
        popup.addChild(inputBox);
        // before the text field, so we see the glyphs
        popup.addChild(input);

        y += input.height + PADDING;

        // finally an OK button
        var ok :SimpleButton = new SimpleTextButton("OK");
        ok.x = WIDTH - PADDING - ok.width;
        ok.y = y;
        ok.addEventListener(MouseEvent.CLICK, function (evt :MouseEvent) :void {
            // TODO: only show the button active if something has been typed
            if (input.text && _control.setMemory(_key, input.text)) {
                _configured(input.text);
                evt.currentTarget.removeEventListener(MouseEvent.CLICK, handleClick);
                _control.clearPopup();
            }
        });
        popup.addChild(ok);

        y += ok.height + PADDING;

        // finally underlay it all with a nice background
        with (popup.graphics) {
            beginFill(0x003366);
            drawRoundRect(0, 0, WIDTH, y, PADDING);
            endFill();
        }

        // and pop it up!
        _control.showPopup("", popup, popup.width, popup.height, 0x6699CC);
    }

    protected var _control :EntityControl;
    protected var _key :String;
    protected var _configured :Function;

    protected static const WIDTH :int = 200;
    protected static const PADDING :int = 10;
}
}
