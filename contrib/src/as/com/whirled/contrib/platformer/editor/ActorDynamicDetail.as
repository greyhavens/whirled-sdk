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
import mx.controls.ComboBox;
import mx.controls.Label;
import mx.events.ListEvent;

import com.whirled.contrib.platformer.board.Board;
import com.whirled.contrib.platformer.piece.Dynamic;

public class ActorDynamicDetail extends Detail
    implements DynamicDetailInterface
{
    public function ActorDynamicDetail (varxml :XML, d :Dynamic, axml :XML)
    {
        super();
        name = varxml.@id;
        if (varxml.hasOwnProperty("@label")) {
            _label = varxml.@label;
        }
        _axml = axml;
        if ((d as Object)[name] != null) {
            _d = Board.loadDynamic((d as Object)[name]);
        }
    }

    override public function createBox () :Box
    {
        var vbox :VBox = new VBox();
        var hbox :HBox = new HBox();
        var label :Label = new Label();
        label.text = name;
        hbox.addChild(label);
        var def :XML = DynamicTree.getDef(_axml, _d);
        if (_label == null) {
            _combo = new ComboBox();
            var options :Array = new Array();
            var index :int;
            for (var ii :int = 0; ii < _axml.dynamicdef.length(); ii++) {
                options.push(_axml.dynamicdef[ii].@label.toString());
                if (def != null && def.@label == _axml.dynamicdef[ii].@label) {
                    index = ii;
                }
            }
            _combo.dataProvider = options;
            _combo.selectedIndex = index;
            _combo.width = 150;
            hbox.addChild(_combo);
            _combo.addEventListener(ListEvent.CHANGE, comboChanged);
        } else {
            label = new Label();
            label.text = _label;
            hbox.addChild(label);
        }
        vbox.addChild(hbox);
        vbox.addChild(_box = new VBox());
        if (_d != null) {
            setDynamic(_d, def);
        } else if (_label != null) {
            createDynamic();
        } else {
            comboChanged(null);
        }
        return vbox;
    }

    public function updateDynamic (d :Dynamic) :void
    {
        for each (var detail :DynamicDetailInterface in _details) {
            detail.updateDynamic(_d);
        }
        (d as Object)[name] = _d.xmlInstance();
    }

    protected function comboChanged (event :ListEvent) :void
    {
        _box.removeAllChildren();
        _label = _combo.selectedLabel;
        createDynamic();
    }

    protected function createDynamic () :void
    {
        var xml :XML = new XML("<" + Board.ACTORS + "/>");
        var def :XML = _axml.dynamicdef.(@label == _label)[0];
        xml.@cname = def.@cname;
        xml.@x = 0;
        xml.@y = 0;
        xml.@id = 0;
        for each (var cxml :XML in def.elements("const")) {
            xml["@" + cxml.@id] = cxml.@value;
        }
        setDynamic(Board.loadDynamic(xml), def);
    }

    protected function setDynamic (d :Dynamic, def :XML) :void
    {
        _d = d;
        _details = new Array();
        DynamicTree.genDetails(_details, _box, def, _d);
    }

    protected var _box :VBox;
    protected var _d :Dynamic;
    protected var _details :Array;
    protected var _axml : XML;
    protected var _combo :ComboBox;
    protected var _label :String;
}
}
