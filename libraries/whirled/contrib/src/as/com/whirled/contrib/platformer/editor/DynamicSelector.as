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

import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
import mx.collections.HierarchicalData;
import mx.events.ListEvent;

public class DynamicSelector extends BaseSelector
{
    public function DynamicSelector (dynamics :XML)
    {
        super();
        _dxml = dynamics;
        _adg.dataProvider = createHD();
    }

    public function getGroup () :String
    {
        return _group;
    }

    public function getConst () :XMLList
    {
        return _const;
    }

    override protected function getColumns () :Array
    {
        var column :AdvancedDataGridColumn = new AdvancedDataGridColumn("Dynamic");
        column.dataField = "@label";
        return [ column ];
    }

    protected function createHD () :HierarchicalData
    {
        var root :XML = <node label="dynamics"/>;
        for each (var node :XML in _dxml.children()) {
            var sroot :XML = <node/>;
            sroot.@label = node.localName();
            for each (var snode :XML in node.children()) {
                var ssroot :XML = <node/>;
                ssroot.@type = snode.@type;
                ssroot.@label = snode.@label;
                sroot.appendChild(ssroot);
            }
            root.appendChild(sroot);
        }
        return new HierarchicalData(root);
    }

    override protected function handleChange (event :ListEvent) :void
    {
        var item :XML = _adg.selectedItem as XML;
        if (item != null && item.parent() != null && item.children().length() == 0) {
            _group = item.parent().@label;
            _const = _dxml.elements(_group)[0].dynamicdef.(@label == item.@label).elements("const");
        } else {
            _group = null;
            _const = null;
        }
        super.handleChange(event);
    }

    override protected function getType (item :XML) :String
    {
        if (item == null || item.parent() == null || item.children().length() != 0) {
            return null;
        }
        return item.@type;
    }

    protected var _dxml :XML;
    protected var _group :String;
    protected var _const :XMLList;
}
}
