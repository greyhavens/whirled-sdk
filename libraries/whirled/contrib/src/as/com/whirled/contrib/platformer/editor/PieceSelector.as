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
import flash.events.MouseEvent;

import mx.containers.Canvas;
import mx.controls.AdvancedDataGrid;
import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;

import mx.collections.Sort;
import mx.collections.SortField;
import mx.collections.XMLListCollection;
import mx.collections.HierarchicalData;
import mx.collections.IHierarchicalData;

import mx.events.ListEvent;

import com.threerings.util.ClassUtil;

import com.whirled.contrib.platformer.piece.PieceFactory;

public class PieceSelector extends BaseSelector
{
    public function PieceSelector (pfac :PieceFactory)
    {
        super();
        _pfac = pfac;
        _adg.dataProvider = createHD();
        _pfac.addEventListener(PieceFactory.PIECE_ADDED, handlePieceAdded);
        _pfac.addEventListener(PieceFactory.PIECE_REMOVED, handlePieceRemoved);
        _pfac.addEventListener(PieceFactory.PIECE_UPDATED, handlePieceUpdated);
    }

    protected override function getColumns () :Array
    {
        var columns :Array = new Array();
        var column :AdvancedDataGridColumn = new AdvancedDataGridColumn("Piece");
        column.dataField = "@label";
        columns.push(column);
        column = new AdvancedDataGridColumn("Sprite");
        column.dataField = "@sprite";
        columns.push(column);
        return columns;
    }

    public function getSelectedPiece () :String
    {
        return _selected;
    }

    public function getRandomPiece () :String
    {
        var item :XML = _adg.selectedItem as XML;
        if (item == null) {
            return null;
        } else if (item.@sprite.length() > 0) {
            return _selected;
        }
        var numPieces :int = 0;
        for each (var node :XML in item.children()) {
            if (node.@sprite.length() > 0) {
                numPieces++;
            }
        }
        if (numPieces == 0) {
            return null;
        }
        var index :int = Math.floor(Math.random() * numPieces);
        for each (node in item.children()) {
            if (node.@sprite.length() > 0) {
                if (index == 0) {
                    return getType(node);
                }
                index--;
            }
        }
        return null;
    }

    protected function addPiece (pdef :XML, root :XML) :void
    {
        var curNode :XML = root;
        for each (var name :String in pdef.@type.toString().split(".")) {
            var node :XML = <node/>;
            node.@label = name;
            if (curNode.children().length() == 0 ||
                    curNode.node.(@label == name).length() == 0) {
                curNode.appendChild(node);
                curNode = node;
            } else {
                curNode = curNode.node.(@label == name)[0];
            }
        }
        curNode.@sprite = pdef.@sprite;
    }

    protected function createHD () :HierarchicalData
    {
        if (_pfac == null) {
            return null;
        }
        var root :XML = <node label="pieces"/>;
        for each (var pdef :XML in _pfac.getPieceDefs()) {
            addPiece(pdef, root);
        }
        return new HierarchicalData(root);
    }

    protected override function getType (item :XML) :String
    {
        if (item != null && item.parent() != null) {
            var type :String = item.@label;
            while (item.parent().parent() != null) {
                item = item.parent();
                type = item.@label + "." + type;
            }
            return type;
        } else {
            return null;
        }
    }

    protected function handlePieceAdded (type :String, xmlDef :XML) :void
    {
        var data :IHierarchicalData = _adg.hierarchicalCollectionView.source;
        var root :XML = _adg.hierarchicalCollectionView.source.getRoot() as XML;
        var newXML :XML;
        var curXML :XML;
        for each (var name :String in type.split(".")) {
            var nodexml :XML = <node/>;
            nodexml.@label = name;
            if (curXML == null) {
                newXML = nodexml;
            } else {
                curXML.appendChild(nodexml);
            }
            curXML = nodexml;
        }
        curXML.@sprite = xmlDef.@sprite;

        _adg.hierarchicalCollectionView.openNode(root);
        while (newXML != null) {
            name = newXML.@label.toString();
            var node :XML = null;
            for each (node in data.getChildren(root)) {
                if (node.@label.toString() == name) {
                    root = node;
                    break;
                }
            }
            if (root != node) {
                while (root != null && !data.canHaveChildren(root)) {
                    var parent :XML = _adg.hierarchicalCollectionView.getParentItem(root);
                    _adg.hierarchicalCollectionView.removeChild(parent, root);
                    root.appendChild(newXML);
                    newXML = root;
                    root = parent;
                }
                _adg.hierarchicalCollectionView.addChild(root, newXML);
                break;
            }
            newXML = newXML.node[0];
            _adg.hierarchicalCollectionView.openNode(root);
        }
        while (newXML != null) {
            _adg.hierarchicalCollectionView.openNode(newXML);
            newXML = newXML.node[0];
        }
        _adg.selectedItem = curXML;
        handleChange(new ListEvent(Event.CHANGE));
    }

    protected function handlePieceRemoved (type :String, xmlDef :XML) :void
    {
        var data :IHierarchicalData = _adg.hierarchicalCollectionView.source;
        var root :Object = _adg.hierarchicalCollectionView.source.getRoot();
        _adg.hierarchicalCollectionView.openNode(root);
        var parents :Array = new Array();
        for each (var name :String in type.split(".")) {
            for each (var node :Object in data.getChildren(root)) {
                if (node.@label.toString() == name) {
                    parents.push(root);
                    root = node;
                    break;
                }
            }
        }
        var parent :Object = root;
        while (parents.length > 0) {
            node = parent;
            parent = parents.pop();
            if (!data.hasChildren(node)) {
                _adg.hierarchicalCollectionView.removeChild(parent, node);
            } else {
                break;
            }
        }
    }

    protected function handlePieceUpdated (type :String, xmlDef :XML) :void
    {
        var data :IHierarchicalData = _adg.hierarchicalCollectionView.source;
        var root :Object = _adg.hierarchicalCollectionView.source.getRoot();
        _adg.hierarchicalCollectionView.openNode(root);
        for each (var name :String in type.split(".")) {
            for each (var node :Object in data.getChildren(root)) {
                if (node.@label.toString() == name) {
                    root = node;
                    break;
                }
            }
        }
        root.@sprite = xmlDef.@sprite;
    }

    protected var _pfac :PieceFactory;
}
}
