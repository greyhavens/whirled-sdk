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

import mx.collections.HierarchicalData;
import mx.containers.Canvas;
import mx.containers.VBox;
import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
import mx.controls.Button;
import mx.events.ListEvent;
import mx.events.FlexEvent;

import com.threerings.util.ClassUtil;

import com.whirled.contrib.platformer.board.Board;

import com.whirled.contrib.platformer.piece.Actor;
import com.whirled.contrib.platformer.piece.Dynamic;

public class DynamicTree extends BaseTree
{
    public function DynamicTree (b :Board, dynamics :XML)
    {
        super(b);
        _dxml = dynamics;
    }

    public function addDynamic (d :Dynamic, group :String) :void
    {
        var xml :XML = <dyn/>;
        xml.@label = ClassUtil.getClassName(d);
        xml.@name = d.id;
        if (addXML(xml, "root." + group) != null) {
            _board.addDynamicIns(d, group);
            _adg.selectedItem = xml;
            handleChange(null);
        }
    }

    override protected function addButtons (box :VBox) :void
    {
        super.addButtons(box);
        var settingsContainer :Canvas = new Canvas();
        settingsContainer.width = 240;
        settingsContainer.height = 250;
        settingsContainer.addChild(_settingsBox = new VBox());
        box.addChild(settingsContainer);
    }

    override protected function getItemName (tree :String) :String
    {
        return "dyn";
    }

    override protected function getColumn () :AdvancedDataGridColumn
    {
        var column :AdvancedDataGridColumn = new AdvancedDataGridColumn("Dynamic");
        column.dataField = "@label";
        return column;
    }

    override protected function createHD () :HierarchicalData
    {
        return new HierarchicalData(buildDynamicTree());
    }

    protected function buildDynamicTree () :XML
    {
        var root :XML = <node>group</node>;
        root.@label = "root";
        root.@name = "root";
        for each (var gname :String in _board.getGroupNames()) {
            var group :XML = <node>group</node>;
            group.@label = gname;
            group.@name = gname;
            root.appendChild(group);
            for each (var node :XML in _board.getDynamicsXML(gname).children()) {
                var xml :XML = <dyn/>;
                xml.@label = node.@cname;
                xml.@name = node.@id;
                group.appendChild(xml);
            }
        }
        return root;
    }

    override protected function updateDetails () :void
    {
        _settingsBox.removeAllChildren();
        _details = null;
        if (_group == _adg.selectedItem || _adg.selectedItem == null) {
            _dynamic = null;
        } else {
            _dynamic = _board.getItem((_adg.selectedItem as XML).@name, _tree) as Dynamic;
        }
        if (_dynamic == null) {
            return;
        }
        var def :XML;
        var group :String = _group.@name;
        var defs :XMLList = _dxml.elements(group)[0].dynamicdef.(
                @cname == ClassUtil.getClassName(_dynamic));
        var dobj :Object = _dynamic;
        if (defs.length() == 1) {
            def = defs[0];
        } else if (defs.length() > 1) {
            for each (var node :XML in defs) {
                def = node;
                for each (var cxml :XML in node.elements("const")) {
                    // fucking as3 can convert booleans consistently
                    if (dobj is Boolean) {
                        if (dobj[cxml.@id] != (cxml.@value == "true")) {
                            def = null;
                            break;
                        }
                    } else if (dobj[cxml.@id] != cxml.@value) {
                        def = null;
                        break;
                    }
                }
                if (def != null) {
                    break;
                }
            }
        }
        if (def == null ||
                (def.elements("var").length() == 0 && def.elements("const").length() == 0)) {
            return;
        }
        _details = new Array();
        for each (var varxml :XML in def.elements("var")) {
            var detail :DynamicDetail = new DynamicDetail(varxml, _dynamic);
            _settingsBox.addChild(detail.createBox());
            _details.push(detail);
        }
        for each (varxml in def.elements("mult")) {
            var mdetail :MultDynamicDetail = new MultDynamicDetail(varxml, _dynamic);
            _settingsBox.addChild(mdetail.createBox());
            _details.push(mdetail);
        }
        for each (varxml in def.elements("const")) {
            if (dobj[varxml.@id.toString()] is Boolean) {
                dobj[varxml.@id.toString()] = varxml.@value == "true";
            } else {
                dobj[varxml.@id.toString()] = varxml.@value;
            }
        }
        var button :Button = new Button();
        button.label = "Update";
        button.addEventListener(FlexEvent.BUTTON_DOWN, updateDynamic);
        _settingsBox.addChild(button);
    }

    protected function updateDynamic (event :FlexEvent) :void
    {
        for each (var detail :DynamicDetailInterface in _details) {
            detail.updateDynamic(_dynamic);
        }
        var group :String = _group.@name;
        _board.updateDynamicIns(_dynamic, group);
    }

    protected var _dxml :XML;
    protected var _settingsBox :VBox;
    protected var _details :Array;
    protected var _dynamic :Dynamic;
}
}
