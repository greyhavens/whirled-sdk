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
import com.threerings.util.StringUtil;
import com.whirled.avrg.AVRGameControl;

/**
 * Panel to display an array of <code>FunctionSpec</code> objects. This includes their names and
 * parameters as well as a way to edit the parameters and call each function individually. A
 * <code>ParameterPanel</code> is used to display each function's parameters.
 * @see com.whirled.contrib.avrg.probe.FunctionSpec
 * @see com.whirled.contrib.avrg.probe.ParameterPanel
 */
public class FunctionPanel extends Sprite
{
    /**
     * Creates a new function panel. Function names are in the left hand column. Clicking on a
     * function name displays the parameter panel on the right. Clicking on the parameter panel
     * call button invokes the function.
     * @param ctrl the game control to use to display feedback when a function is called
     * @param functions array of <code>FunctionSpec</code> objects
     * @param sequenced whether to pass in an extra sequence paramter when invoking functions - the
     * passed value is incremented each time a call is made
     */
    public function FunctionPanel (ctrl :AVRGameControl, functions :Array, sequenced :Boolean)
    {
        var depth :int = 40;
        _ctrl = ctrl;
        _sequenced = sequenced;

        _output = new TextField();
        _output.width = 349;
        _output.height = 99;
        _output.y = 150 - depth;
        _output.border = true;
        _output.wordWrap = true;
        addChild(_output);

        var maxPerPage :int = _output.y / 20 - 1;
        if (functions.length <= maxPerPage) {
            addChild(setupGrid(functions));

        } else {
            var groups :TabPanel = new TabPanel();
            var tabNum :int = 1;
            for (var start :int = 0; start < functions.length; start += maxPerPage) {
                groups.addTab("group" + tabNum, 
                    new Button("G" + tabNum), 
                    setupGrid(functions.slice(start, start + maxPerPage)));
                tabNum++;
            }
            addChild(groups);
        }

    }

    protected function setupGrid (functions :Array) :GridPanel
    {
        var heights :Array = [];
        var ii :int;
        for (ii = 0; ii < functions.length; ++ii) {
            heights.push(20);
        }

        var grid :GridPanel = new GridPanel(
            [150], heights);

        for (ii = 0; ii < functions.length; ++ii) {
            var spec :FunctionSpec = functions[ii] as FunctionSpec;
            var params :ParameterPanel = new ParameterPanel(spec.parameters, spec.name);
            params.x = 150;
            params.visible = false;
            addChild(params);
            _functions[spec.name] = new FunctionEntry(spec, params);

            var fnButt :Button = new Button(spec.name, spec.name);
            grid.addCell(0, ii, fnButt);
            fnButt.addEventListener(ButtonEvent.CLICK, handleFunctionClick);
            params.callButton.addEventListener(ButtonEvent.CLICK, handleCallClick);
        }

        return grid;
    }

    protected function handleFunctionClick (evt :ButtonEvent) :void
    {
        var entry :FunctionEntry = _functions[evt.action];
        if (entry == null) {
            output("Function " + evt.action + " not found");
            return;
        }

        if (entry != _selected) {
            if (_selected != null) {
                _selected.params.visible = false;
            }
            _selected = entry;
            _selected.params.visible = true;
        }
    }

    protected function parseParameters (entry :FunctionEntry, local :Boolean) :Array
    {
        var inputs :Array = entry.params.getInputs();
        var params :Array = entry.spec.parameters;
        for (var ii :int = 0; ii < inputs.length; ++ii) {
            if (params[ii] is CallbackParameter) {
                if (local) {
                    inputs[ii] = makeGenericCallback(entry.spec);
                }
            } else {
                inputs[ii] = params[ii].parse(inputs[ii]);
            }
        }
        return inputs;
    }

    protected function makeGenericCallback (fn :FunctionSpec) :Function
    {
        function callback (...args) :void {
            _ctrl.local.feedback("Callback from " + fn.name + " invoked with " + 
                                 "arguments " + StringUtil.toString(args));
        }

        return callback;
    }

    protected function handleCallClick (evt :ButtonEvent) :void
    {
        if (_selected == null) {
            return;
        }

        try {
            var params :Array = parseParameters(_selected, true);
            if (_sequenced) {
                var sequenceId :int = ++_sequenceId;
                output("Calling " + _selected.spec.name + " with arguments " + 
                    ClientPanel.toString(params) + " and sequence id " + sequenceId);
                params.unshift(sequenceId);

            } else {
                output("Calling " + _selected.spec.name + " with arguments " + 
                    ClientPanel.toString(params));
            }
            var value :Object = _selected.spec.func.apply(null, params);
            output("Result: " + ClientPanel.toString(value));

        } catch (e :Error) {
            var msg :String = e.getStackTrace();
            if (msg == null) {
                msg = e.toString();
            }
            output(msg);
        }
    }

    protected function output (str :String) :void
    {
        _output.appendText(str);
        _output.appendText("\n");
        _output.scrollV = _output.maxScrollV;
    }

    protected var _ctrl :AVRGameControl;
    protected var _functions :Object = {};
    protected var _output :TextField;
    protected var _selected :FunctionEntry;
    protected var _sequenced :Boolean;
    protected static var _sequenceId :int = 0;
}

}

import com.whirled.contrib.avrg.probe.FunctionSpec;
import com.whirled.contrib.avrg.probe.ParameterPanel;

class FunctionEntry
{
    public var spec :FunctionSpec;
    public var params :ParameterPanel;

    public function FunctionEntry (spec :FunctionSpec, params :ParameterPanel)
    {
        this.spec = spec;
        this.params = params;
    }
}
