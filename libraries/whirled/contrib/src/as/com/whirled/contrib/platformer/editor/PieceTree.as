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
import flash.events.KeyboardEvent;

import mx.containers.Canvas;
import mx.containers.HBox;
import mx.containers.VBox;
import mx.controls.Tree;
import mx.controls.AdvancedDataGrid;
import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
import mx.controls.TextInput;
import mx.controls.Button;

import mx.collections.Sort;
import mx.collections.SortField;
import mx.collections.XMLListCollection;
import mx.collections.HierarchicalData;
import mx.collections.IHierarchicalData;

import mx.events.FlexEvent;

import com.threerings.util.ClassUtil;
import com.threerings.util.KeyboardCodes;

import com.whirled.contrib.platformer.board.Board;

import com.whirled.contrib.platformer.piece.Piece;

public class PieceTree extends BaseTree
{
    public function PieceTree (b :Board)
    {
        super(b);
        _adg.setKeyPressedHandler(keyPressed);
    }

    public function addPiece (p :Piece) :void
    {
        var xml :XML = <piece/>;
        xml.@label = p.type.substr(p.type.lastIndexOf(".") + 1);
        xml.@name = p.id;
        if (addXML(xml) != null) {
            _board.addPiece(p, _tree);
            _adg.selectedItem = xml;
            handleChange(null);
        }
    }

    public function addGroup (name :String) :void
    {
        var xml :XML = <node>group</node>;
        xml.@label = name;
        xml.@name = name;
        var oldTree :String = _tree;
        if (addXML(xml) != null) {
            _board.addPieceGroup(oldTree, name);
        }
    }

    protected override function getItemName (tree :String) :String
    {
        return "piece";
    }

    protected override function addButtons (box :VBox) :void
    {
        var hbox :HBox = new HBox();
        hbox.addChild(EditView.makeButton("Delete", function () :void {
            deleteSelected();
        }));
        hbox.addChild(EditView.makeButton("-", function () :void {
            moveSelectedBack();
        }));
        hbox.addChild(EditView.makeButton("+", function () :void {
            moveSelectedForward();
        }));
        hbox.addChild(EditView.makeButton("flip", function () :void {
            flipSelected();
        }));
        box.addChild(hbox);
        hbox = new HBox();
        hbox.addChild(EditView.makeButton("Parent", function () :void {
            moveSelectedUp();
        }));
        hbox.addChild(EditView.makeButton("Child", function () :void {
            moveSelectedDown();
        }));
        box.addChild(hbox);
        hbox = new HBox();
        var input :TextInput = new TextInput();
        input.width = 100;
        hbox.addChild(input);
        hbox.addChild(EditView.makeButton("AddGroup", function () :void {
            if (input.text != "") {
                addGroup(input.text);
            }
        }));
        box.addChild(hbox);
    }

    protected override function getColumn () :AdvancedDataGridColumn
    {
        var column :AdvancedDataGridColumn = new AdvancedDataGridColumn("Piece");
        column.dataField = "@label";
        return column;
    }

    protected override function createHD () :HierarchicalData
    {
        return new HierarchicalData(convertPiecenode(_board.getPieceTreeXML()));
    }

    protected function convertPiecenode (piecenode :XML) :XML
    {
        var group :XML = <node>group</node>;
        group.@label = piecenode.@name;
        group.@name = piecenode.@name;
        for each (var node :XML in piecenode.children()) {
            if (node.localName() == "piece") {
                var xml :XML = <piece/>;
                xml.@label = node.@type.substr(node.@type.lastIndexOf(".") + 1);
                xml.@name = node.@id;
                group.appendChild(xml);
            } else {
                group.appendChild(convertPiecenode(node));
            }
        }
        return group;
    }

    protected function moveSelectedForward () :void
    {
        if (!canModifySelected()) {
            return;
        }
        var selected :XML = _adg.selectedItem as XML;
        var group :XML = _group;
        if (group == selected) {
            group = group.parent();
        }
        var index :int = selected.childIndex();
        if (index >= group.children().length() - 1) {
            return;
        }

        _adg.selectedItem = null;
        _adg.hierarchicalCollectionView.removeChild(group, selected);
        _adg.hierarchicalCollectionView.addChildAt(group, selected, index);
        _adg.selectedItem = selected;
        handleChange(null);
        _board.moveItemForward(selected.@name, findTree(group));
    }

    protected function moveSelectedBack () :void
    {
        if (!canModifySelected()) {
            return;
        }
        var selected :XML = _adg.selectedItem as XML;
        var group :XML = _group;
        if (group == selected) {
            group = group.parent();
        }
        var index :int = selected.childIndex();
        if (index <= 1) {
            return;
        }
        _adg.selectedItem = null;
        _adg.hierarchicalCollectionView.removeChild(group, selected);
        _adg.hierarchicalCollectionView.addChildAt(group, selected, index - 2);
        _adg.selectedItem = selected;
        handleChange(null);
        _board.moveItemBack(selected.@name, findTree(group));
    }

    protected function moveSelectedUp () :void
    {
        if (!canModifySelected()) {
            return;
        }
        var selected :XML = _adg.selectedItem as XML;
        var group :XML = _group;
        if (group == selected) {
            group = group.parent();
        }
        var newGroup :XML = group.parent();
        if (newGroup == null || newGroup == _root) {
            return;
        }
        var index :int = group.childIndex();
        _adg.selectedItem = null;
        _adg.hierarchicalCollectionView.removeChild(group, selected);
        _adg.hierarchicalCollectionView.addChildAt(newGroup, selected, index - 1);
        _adg.selectedItem = selected;
        handleChange(null);
        _board.moveItemUp(selected.@name, findTree(group));
    }

    protected function moveSelectedDown () :void
    {
        if (!canModifySelected()) {
            return;
        }
        var data :IHierarchicalData = _adg.hierarchicalCollectionView.source;
        var selected :XML = _adg.selectedItem as XML;
        var group :XML = _group;
        if (group == selected) {
            group = group.parent();
        }
        var index :int = selected.childIndex();
        var len :int = group.children().length();
        var newgroup :XML;
        for (var ii :int = index + 1; ii < len; ii++) {
            if (data.canHaveChildren(group.children()[ii])) {
                newgroup = group.children()[ii];
                break;
            }
        }
        if (newgroup == null) {
            return;
        }
        _adg.selectedItem = null;
        _adg.hierarchicalCollectionView.removeChild(group, selected);
        _adg.hierarchicalCollectionView.openNode(newgroup);
        _adg.hierarchicalCollectionView.addChildAt(newgroup, selected, 0);
        _adg.selectedItem = selected;
        handleChange(null);
        _board.moveItemDown(selected.@name, findTree(group));
    }

    protected function flipSelected () :void
    {
        if (_adg.selectedItem == null || _adg.selectedItem == _group) {
            return;
        }
        _board.flipPiece(_adg.selectedItem.@name, _tree);
    }

    protected function keyPressed (event :KeyboardEvent) :Boolean
    {
        if (event.keyCode == KeyboardCodes.D) {
            moveSelectedDown();
        } else if (event.keyCode == KeyboardCodes.A) {
            moveSelectedUp();
        } else if (event.keyCode == KeyboardCodes.S) {
            moveSelectedForward();
        } else if (event.keyCode == KeyboardCodes.W) {
            moveSelectedBack();
        } else {
            return false;
        }
        return true;
    }
}
}
