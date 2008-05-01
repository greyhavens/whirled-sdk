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

package com.whirled.contrib.simplegame.objects {

import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.components.MeterComponent;

import flash.display.DisplayObject;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

public class IntTextMeter extends SceneObject
    implements MeterComponent
{
    public function IntTextMeter ()
    {
        _display = new TextField();
        _display.autoSize = TextFieldAutoSize.LEFT
        _display.selectable = false;
    }

    // from SceneObject
    override public function get displayObject () :DisplayObject
    {
        return _display;
    }

    public function get maxValue () :Number
    {
        return _maxValue;
    }

    public function set maxValue (val :Number) :void
    {
        _maxValue = val;
        _minValue = Math.min(_minValue, _maxValue);
        _value = Math.min(_value, _maxValue);
        _value = Math.max(_value, _minValue);

        _dirty = true;
    }

    public function get minValue () :Number
    {
        return _minValue;
    }

    public function set minValue (val :Number) :void
    {
        _minValue = val;
        _maxValue = Math.max(_maxValue, _minValue);
        _value = Math.min(_value, _maxValue);
        _value = Math.max(_value, _minValue);

        _dirty = true;
    }

    public function get value () :Number
    {
        return _value;
    }

    public function set value (val :Number) :void
    {
        _value = Math.min(val, _maxValue);
        _value = Math.max(_value, _minValue);

        _dirty = true;
    }

    public function get textColor () :uint
    {
        return _display.textColor;
    }

    public function set textColor (val :uint) :void
    {
        _display.textColor = textColor;
        _dirty = true;
    }

    public function get font () :String
    {
        return _display.defaultTextFormat.font;
    }

    public function set font (newFont :String) :void
    {
        _display.defaultTextFormat.font = newFont;
        _dirty = true;
    }

    // from SimObject
    override protected function update (dt :Number) :void
    {
        if (_dirty) {
            updateDisplay();
        }

        super.update(dt);
    }

    public function updateDisplay () :void
    {
        var textString :String = Math.floor(_value) + "/" + Math.floor(_maxValue);
        _display.text = textString;
    }

    protected var _dirty :Boolean;

    protected var _maxValue :Number;
    protected var _minValue :Number;
    protected var _value :Number;

    protected var _display :TextField;
}

}
