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

import mx.controls.CheckBox;
import mx.controls.TextInput;
import mx.core.UIComponent;

import com.whirled.contrib.platformer.piece.Dynamic;

public class DynamicDetail extends Detail
    implements DynamicDetailInterface
{

    public function DynamicDetail (varxml :XML, d:Dynamic)
    {
        super();
        name = varxml.@id;
        if (varxml.@type == "checkbox") {
            _checkbox = new CheckBox();
            _checkbox.selected = (d as Object)[name];
        } else {
            _input = new TextInput();
            _input.text = (d as Object)[name];
        }
    }

    public function updateDynamic (d :Dynamic) :void
    {
        if (_checkbox != null) {
            (d as Object)[name] = _checkbox.selected;
        } else {
            (d as Object)[name] = _input.text;
        }
    }

    override protected function input () :UIComponent
    {
        return _checkbox != null ? _checkbox : _input;
    }

    protected var _input :TextInput;
    protected var _checkbox :CheckBox;
}
}
