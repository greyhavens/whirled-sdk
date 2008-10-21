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
import flash.display.Sprite;
import flash.text.TextFieldAutoSize;

/**
 * A very simple sprite that may be used to test mobs.
 * @see com.whirled.contrib.avrg.probe.ClientPanel
 */
public class MobSprite extends Sprite
{
    /**
     * Creates a new mob sprite.
     * @param id a string to render in the mob sprite
     */
    public function MobSprite (id :String)
    {
        _text = new TextField();
        addChild(_text);

        _text.text = id;
        _text.selectable = false;
        _text.autoSize = TextFieldAutoSize.CENTER;
        _text.x = -_text.width / 2;
        _text.y = -_text.height / 2;

        graphics.beginFill(0x7f7fff);
        graphics.drawRect(-10, -5, 20, 10);
        graphics.endFill();

        scaleX = 3;
        scaleY = 3;
    }

    protected var _text :TextField;
}

}
