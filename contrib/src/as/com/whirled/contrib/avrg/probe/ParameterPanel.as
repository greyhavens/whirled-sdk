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

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import com.threerings.util.StringUtil;

/**
 * A panel for displaying controls for an array of <code>Parameter</code> objects and returning
 * the parsed values. Also displays a title button intended to be used to calling the parent
 * function.
 */
public class ParameterPanel extends Sprite
{
    /** Fixed height of a parameter input line. */
    public static const CELL_HEIGHT :int = 25;

    /**
     * Creates a new parameter panel. The title will be used as the call button.
     * @param parameters array of <code>Parameter</code> objects to display controls for
     * @param title the title of the panel
     */
    public function ParameterPanel (parameters :Array, title :String=null)
    {
        var defaultNulls :Boolean = true;

        var row :int;
        var heights :Array = [];
        _entries = [];
        for (row = 0; row < parameters.length; ++row) {
            heights.push(CELL_HEIGHT);
            var param :Parameter = parameters[row] as Parameter;
            var label :Button = new Button(
                param.name + " :" + param.typeDisplay, param.name);
            label.addEventListener(ButtonEvent.CLICK, handleLabelClick);
            var input :TextField = new TextField();
            //input.autoSize = TextFieldAutoSize.LEFT;
            input.border = true;
            if (param is CallbackParameter) {
                input.textColor = 0x808080;
                input.borderColor = 0x808080;
                input.text = "callback";
            } else {
                input.type = TextFieldType.INPUT;
            }
            if (param.optional) {
                input.visible = false;
            }
            _entries.push(new ParameterEntry(param, label, input));
        }

        heights.push(CELL_HEIGHT);
        _grid = new GridPanel([70, 30, 95], heights);

        for (row = 0; row < _entries.length; ++row) {
            var entry :ParameterEntry = _entries[row];
            _grid.addCell(0, row + 1, entry.label);
            _grid.addCell(2, row + 1, entry.input);
            entry.input.width = _grid.getCellSize(2, row).x;
            entry.input.height = _grid.getCellSize(2, row).y - 3;
            if (entry.param.nullable) {
                var nullButton :Button = new Button("", entry.param.name);
                _grid.addCell(1, row + 1, nullButton);
                nullButton.addEventListener(ButtonEvent.CLICK, handleNullClick);
                setNull(entry, nullButton, defaultNulls);
            }
        }


        if (title == null) {
            title = "[Call]";
        }
        
        _call = new Button(title, "call");
        _grid.addCell(0, 0, _call);

        addChild(_grid);
    }

    /**
     * The button in the panel which will call the function.
     */
    public function get callButton () :Button
    {
        return _call;
    }

    /**
     * Gets all the input values as text. Values from the first omitted optional parameter are not
     * included.
     * @return array of Strings, one per parameter that is enabled
     */
    public function getInputs () :Array
    {
        var args :Array = [];
        for each (var entry :ParameterEntry in _entries) {
            if (!entry.input.visible) {
                break;
            }
            args.push(entry.isNull ? null : entry.input.text);
        }
        return args;
    }

    protected function handleLabelClick (evt :ButtonEvent) :void
    {
        var paramName :String = evt.action;
        var clicked :int;
        for (clicked = 0; clicked < _entries.length; ++clicked) {
            if (_entries[clicked].param.name == paramName) {
                break;
            }
        }

        if (clicked == _entries.length) {
            trace("Parameter not found: " + evt);
        }

        var row :int;
        var entry :ParameterEntry = _entries[clicked] as ParameterEntry;
        if (entry.input.visible && entry.param.optional) {
            for (row = clicked; row < _entries.length; ++row) {
                _entries[row].input.visible = false;
            }

        } else if (!entry.input.visible) {
            for (row = 0; row <= clicked; ++row) {
                _entries[row].input.visible = true;
            }
        }
    }

    protected function handleNullClick (evt :ButtonEvent) :void
    {
        var paramName :String = evt.action;
        var clicked :int;
        for (clicked = 0; clicked < _entries.length; ++clicked) {
            if (_entries[clicked].param.name == paramName) {
                break;
            }
        }

        if (clicked == _entries.length) {
            trace("Parameter not found: " + evt);
            return;
        }

        var entry :ParameterEntry = _entries[clicked];
        var button :Button = evt.target as Button;
        setNull(entry, button, !entry.isNull);
    }

    protected function setNull (
        entry :ParameterEntry, 
        button :Button, 
        isNull :Boolean) :void
    {
        if (!entry.param.nullable) {
            trace("Parameter can't be null: " + entry.param);
            return;
        }

        entry.isNull = isNull;
        if (isNull || entry.param is CallbackParameter) {
            entry.input.type = TextFieldType.DYNAMIC;
            entry.input.textColor = 0x808080;
        } else {
            entry.input.type = TextFieldType.INPUT;
            entry.input.textColor = 0x000000;
        }

        if (isNull) {
            button.text = "(null)";
            entry.input.border = false;
        } else {
            button.text = "(!null)";
            entry.input.border = true;
        }
    }

    protected var _call :Button;
    protected var _serverCall :Button;
    protected var _grid :GridPanel;
    protected var _entries :Array;
}

}

import flash.text.TextField;
import com.whirled.contrib.avrg.probe.Parameter;
import com.whirled.contrib.avrg.probe.Button;

class ParameterEntry
{
    public var param :Parameter;
    public var label :Button;
    public var input :TextField;
    public var isNull :Boolean;

    public function ParameterEntry (
        param :Parameter,
        label :Button,
        input :TextField)
    {
        this.param = param;
        this.label = label;
        this.input = input;
        this.isNull = false;
    }
}
