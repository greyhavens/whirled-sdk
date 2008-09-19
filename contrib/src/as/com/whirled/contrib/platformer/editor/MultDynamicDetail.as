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

package com.whirled.contrib.platformer.editor {

import mx.containers.Box;
import mx.containers.HBox;
import mx.containers.VBox;
import mx.controls.Button;
import mx.controls.TextInput;
import mx.controls.Label;
import mx.events.FlexEvent;

import flash.system.ApplicationDomain;

import com.whirled.contrib.platformer.piece.Dynamic;

public class MultDynamicDetail extends Detail
    implements DynamicDetailInterface
{
    public function MultDynamicDetail (mulxml :XML, d :Dynamic)
    {
        super();
        _mulxml = mulxml;
        name = mulxml.@id;
        _arr = (d as Object)[name];
        var ii :int = 0;
        _class = ApplicationDomain.currentDomain.getDefinition(mulxml["@class"]) as Class;
        while (ii < _arr.length) {
            ii = addInputs(ii);
        }
    }

    override public function createBox () :Box
    {
        _box = new VBox();
        var label :Label = new Label;
        label.text = name;
        _box.addChild(label);
        for (var ii :int = 0; ii < _inputs.length; ii++) {
            addDetail(ii);
        }
        var hbox :HBox = new HBox();
        var button :Button = new Button();
        button.label = "+";
        button.addEventListener(FlexEvent.BUTTON_DOWN, addVar);
        hbox.addChild(button);
        button = new Button();
        button.label = "-";
        button.addEventListener(FlexEvent.BUTTON_DOWN, removeVar);
        hbox.addChild(button);
        _box.addChild(hbox);
        return _box;
    }

    public function updateDynamic (d :Dynamic) :void
    {
        _arr = new Array();
        for each (var input :TextInput in _inputs) {
            _arr.push(new _class(input.text));
        }
        (d as Object)[name] = _arr;
    }

    protected function addInputs (idx :int) :int
    {
        for each (var varxml :XML in _mulxml.elements("var")) {
            addInput(idx, varxml);
            idx++;
        }
        return idx;
    }

    protected function addInput (idx :int, varxml :XML) :void
    {
        var label :Label = new Label();
        label.text = varxml.@id + ":";
        _labels.push(label);
        var input :TextInput = new TextInput();
        if (idx < _arr.length) {
            input.text = _arr[idx];
        }
        _inputs.push(input);
    }

    protected function addDetail (idx :int) :void
    {
        var hbox :HBox = new HBox();
        hbox.addChild(_labels[idx]);
        hbox.addChild(_inputs[idx]);
        _box.addChildAt(hbox, idx + 1);
    }

    protected function addVar (event :FlexEvent) :void
    {
        var idx :int = _inputs.length;
        var tot :int = addInputs(idx);
        for ( ; idx < tot; idx++) {
            addDetail(idx);
        }
    }

    protected function removeVar (event :FlexEvent) :void
    {
        var idx :int = _inputs.length;
        var num :int = _mulxml.elements("var").length();
        _inputs.splice(idx - num, num);
        _labels.splice(idx - num, num);
        for (var ii :int = 0; ii < num; ii++) {
            _box.removeChildAt(idx - ii);
        }
    }

    protected var _arr :Array;
    protected var _inputs :Array = new Array();
    protected var _labels :Array = new Array();
    protected var _mulxml :XML;
    protected var _box :VBox;
    protected var _class :Class;
}
}
