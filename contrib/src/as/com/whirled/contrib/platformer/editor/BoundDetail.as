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

import mx.collections.ArrayCollection;
import mx.containers.Box;
import mx.containers.HBox;
import mx.containers.VBox;

import mx.controls.ComboBox;
import mx.controls.TextInput;
import mx.controls.Label;

import com.whirled.contrib.platformer.piece.BoundData;
import com.whirled.contrib.platformer.piece.BoundedPiece;

public class BoundDetail extends Detail
{
    public function BoundDetail (attr :XML = null)
    {
        super(attr);
        _x = new TextInput();
        _x.width = 30;
        _y = new TextInput();
        _y.width = 30;
        _type = new ComboBox();
        _type.dataProvider = new ArrayCollection([
            { label:"none", data:BoundData.NONE },
            { label:"all", data:BoundData.ALL },
            { label:"outer", data:BoundData.OUTER },
            { label:"inner", data:BoundData.INNER } ]);
        _proj = new ComboBox();
        _proj.dataProvider = new ArrayCollection([
            { label:"none", data:BoundData.S_NONE },
            { label:"all", data:BoundData.S_ALL },
            { label:"outer", data:BoundData.S_OUTER },
            { label:"inner", data:BoundData.S_INNER } ]);
        if (attr != null) {
            _y.text = attr.@y;
            _x.text = attr.@x;
            _type.selectedIndex = BoundData.getNormalBound(attr.@type);
            _proj.selectedIndex = BoundData.getShotBound(attr.@type) >> 8;
        }
    }

    override public function createBox () :Box
    {
        var box :HBox = new HBox();
        var label :Label = new Label();
        label.text = "x:";
        box.addChild(label);
        box.addChild(_x);
        label = new Label();
        label.text = "y:";
        box.addChild(label);
        box.addChild(_y);
        var vbox :VBox = new VBox();
        vbox.addChild(_type);
        vbox.addChild(_proj);
        box.addChild(vbox);
        return box;
    }

    override public function setData (defxml :XML) :void
    {
        if (_x.text == "" || _y.text == "") {
            return;
        }
        var xml :XML = <bound/>;
        xml.@x = _x.text;
        xml.@y = _y.text;
        xml.@type = _type.selectedItem.data | _proj.selectedItem.data;
        defxml.appendChild(xml);
    }

    protected var _x :TextInput;
    protected var _y :TextInput;
    protected var _type :ComboBox;
    protected var _proj :ComboBox;
}
}
