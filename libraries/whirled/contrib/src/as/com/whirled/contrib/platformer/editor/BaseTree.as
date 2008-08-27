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

import flash.events.Event;

import mx.collections.HierarchicalData;
import mx.collections.IHierarchicalData;
import mx.containers.Canvas;
import mx.containers.HBox;
import mx.containers.VBox;
import mx.controls.AdvancedDataGrid;
import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
import mx.core.ScrollPolicy;
import mx.events.ListEvent;

import com.whirled.contrib.platformer.board.Board;

public class BaseTree extends Canvas
{
    public function BaseTree (b :Board)
    {
        _board = b;
        _adg = new PieceGrid();
        _adg.width = 240;
        _adg.height = 400;
        _adg.showHeaders = false;
        _adg.horizontalScrollPolicy = ScrollPolicy.AUTO;
        _adg.columns = [ getColumn() ];
        _adg.dataProvider = createHD();
        _adg.addEventListener(ListEvent.CHANGE, handleChange);
        addChild(_adg);
        callLater(postinit);
        var box :VBox = new VBox();
        box.y = 400;
        addButtons(box);
        addChild(box);
    }

    public function getTree () :String
    {
        return _tree;
    }

    public function getSelected () :String
    {
        return (_adg.selectedItem == null ? null : _adg.selectedItem.@name);
    }

    public function selectTree (tree :String) :void
    {
        var root :XML = _root;
        tree = tree.replace(/root(\.)*/, "");
        if (tree != "") {
            for each (var node :String in tree.split(".")) {
                if (!_adg.hierarchicalCollectionView.contains(root)) {
                    return;
                }
                _adg.hierarchicalCollectionView.openNode(root);
                root = root.node.(@name == node)[0];
            }
        }
        _adg.hierarchicalCollectionView.openNode(root);
        _group = root;
    }

    public function selectItem (tree :String, name :String) :void
    {
        selectTree(tree);
        _adg.selectedItem = _group.elements(getItemName(tree)).(@name == name)[0];
        handleChange(null);
    }

    public function addXML (xml :XML, tree :String = null) :String
    {
        if (tree != null) {
            selectTree(tree);
        }
        var data :IHierarchicalData = _adg.hierarchicalCollectionView.source;
        var root :XML = _group;
        if (_root == root || !data.canHaveChildren(_group) ||
                _group.node.(@name == xml.@name).length() > 0) {
            return null;
        }
        _adg.hierarchicalCollectionView.addChild(root, xml);
        _adg.hierarchicalCollectionView.openNode(_group);
        _adg.selectedItem = _group;
        handleChange(null);
        return _tree;
    }

    protected function getItemName (tree :String) :String
    {
        return "item";
    }

    protected function addButtons (box :VBox) :void
    {
        var hbox :HBox = new HBox();
        hbox.addChild(EditView.makeButton("Delete", function () :void {
            deleteSelected();
        }));
        box.addChild(hbox);
    }

    protected function getColumn () :AdvancedDataGridColumn
    {
        var column :AdvancedDataGridColumn = new AdvancedDataGridColumn("node");
        column.dataField = "@label";
        return column;
    }

    protected function postinit () :void
    {
        _adg.hierarchicalCollectionView.filterFunction = function (item :Object) :Boolean {
            return (item is XML) && item.nodeKind() != "text";
        };
        _root = _adg.hierarchicalCollectionView.source.getRoot() as XML;
        handleChange(new ListEvent(Event.CHANGE))
    }

    protected function createHD () :HierarchicalData
    {
        return new HierarchicalData();
    }

    protected function scrollToSelected () :void
    {
        _adg.scrollToIndex(_adg.selectedIndex);
    }

    protected function deleteSelected () :String
    {
        if (!canModifySelected()) {
            return null;
        }
        var selected :XML = _adg.selectedItem as XML;
        var name :String = selected.@name.toString();
        _adg.selectedItem = selected.parent();
        handleChange(null);
        _adg.hierarchicalCollectionView.removeChild(_group, selected);
        _board.removeItem(name, _tree);
        return name;
    }

    protected function canModifySelected () :Boolean
    {
        return !(_adg.selectedItem == null || _adg.selectedItem.parent() == null ||
                _adg.selectedItem.parent() == _root);
    }

    protected function findTree (item :XML) :String
    {
        var tree :String = item.@name;
        while (item.parent() != null) {
            item = item.parent();
            tree = item.@name + "." + tree;
        }
        return tree;
    }

    protected function handleChange (event :ListEvent) :void
    {
        var item :XML = _adg.selectedItem as XML;
        if (item == null) {
            _group = _root;
            _tree = "root";
            return;
        }
        if (item.children().length() == 0) {
            _group = item = item.parent();
        } else {
            _group = item;
        }
        _tree = findTree(item);
        if (item != null) {
            callLater(scrollToSelected);
        }
        dispatchEvent(new ListEvent(ListEvent.CHANGE));
    }

    protected var _adg :PieceGrid;
    protected var _board :Board;
    protected var _tree :String;
    protected var _group :XML;
    protected var _root :XML;
}
}
