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

import flash.geom.Point;

import mx.containers.Box;
import mx.containers.HBox;
import mx.containers.VBox;
import mx.controls.Button;
import mx.controls.RadioButtonGroup;
import mx.controls.RadioButton;
import mx.controls.Text;
import mx.events.FlexEvent;
import mx.events.ItemClickEvent;

import com.threerings.util.Log;

import com.whirled.contrib.platformer.piece.Piece;

public class BoundsDetail extends Detail
{
    public function BoundsDetail (attr :XML, editSprite :PieceEditSprite, 
        pieceDetails :PieceEditDetails)
    {
        super(attr);
        _editSprite = editSprite;
        _pieceDetails = pieceDetails;
        for each (var bdef :XML in attr.bound) {
            _bounds.push(new BoundDetail(bdef));
        }
    }

    override public function createBox () :Box
    {
        _topBox = new VBox();

        var buttonBox :HBox = new HBox();
        var rbg :RadioButtonGroup = new RadioButtonGroup();
        rbg.addEventListener(ItemClickEvent.ITEM_CLICK, modeClicked);
        var rb :RadioButton = new RadioButton();
        rb.label = NUMBER_MODE;
        rb.group = rbg;
        rb.selected = true;
        buttonBox.addChild(rb);
        rb = new RadioButton();
        rb.label = MOUSE_MODE;
        rb.group = rbg;
        buttonBox.addChild(rb);
        _topBox.addChild(buttonBox);

        _numberBox = new VBox();
        updateNumberBox();
        _topBox.addChild(_numberBox);

        _mouseBox = new VBox();
        _mouseBox.percentWidth = 100;
        _mouseModeLabel = new Text();
        _mouseModeLabel.percentWidth = 100;
        _mouseModeLabel.setStyle("textAlign", "center");
        _mouseModeLabel.text = EDIT_MODE_LABEL;
        _mouseBox.addChild(_mouseModeLabel);

        return _topBox;
    }

    override public function setData (defxml :XML) :void
    {
        var xml :XML = <bounds/>;
        for each (var bound :BoundDetail in _bounds) {
            bound.setData(xml);
        }
        defxml.appendChild(xml);
    }

    public function nodeSelected (pos :Point) :void
    {
        while(_mouseBox.numChildren > 1) {
            _mouseBox.removeChildAt(1);
        }

        if (pos == null) {
            return;
        }

        var bound :BoundDetail = findBound(pos);
        if (bound == null) {
            log.warning("bound not found to select [" + pos + "]");
            return;
        }

        _mouseBox.addChild(bound.createReactiveBox(function (...ignored) :void {
            _nodeMoveLayer.setBoundColor(bound.getPosition(), bound.getColor());
            _pieceDetails.updatePiece();
        }, function (...ignored) :void {
            var idx :int = _bounds.indexOf(bound);
            if (idx < 0) {
                log.warning("bound not found to remove [" + bound.getPosition() + "]");
                return;
            }

            _bounds.splice(idx, 1);
            _nodeMoveLayer.removeBound(bound.getPosition());
            _pieceDetails.updatePiece();
        }));
    }

    public function boundMoved (oldPos :Point, newPos :Point) :void
    {
        var bound :BoundDetail = findBound(oldPos);
        if (bound == null) {
            log.warning("bound not found to move [" + oldPos + ", " + newPos + "]");
            return;
        }

        bound.setPosition(newPos);
        _pieceDetails.updatePiece();
    }

    public function addClickBound (pos :Point, idx :int) :void
    {
        var bdef :XML = <bound/>;
        bdef.@x = pos.x;
        bdef.@y = pos.y;
        if (_bounds.length == 0) {
            bdef.@type = 0;
        } else {
            var prevBound :BoundDetail = _bounds[idx - 1] as BoundDetail;
            bdef.@type = prevBound.getType();
        }
         
        var bound :BoundDetail = new BoundDetail(bdef);
        if (idx == _bounds.length) {
            _bounds.push(bound);
        } else {
            _bounds.splice(idx, 0, bound);
        }

        _nodeMoveLayer.addBoundMarker(bound.getPosition(), bound.getColor(), idx);
        _pieceDetails.updatePiece();
    }

    public function modeChanged (mode :int) :void
    {
        if (mode == NodeMoveLayer.ADD_MODE) {
            _mouseModeLabel.text = ADD_MODE_LABEL;
        } else if (mode == NodeMoveLayer.EDIT_MODE) {
            _mouseModeLabel.text = EDIT_MODE_LABEL;
        }
    }

    protected function findBound (pos :Point) :BoundDetail
    {
        for each (var bound :BoundDetail in _bounds) {
            if (bound.getPosition().equals(pos)) {
                return bound;
            }
        }
        return null;
    }

    protected function updateNumberBox () :void
    {
        while(_numberBox.numChildren > 0) {
            _numberBox.removeChildAt(0);
        }

        for each (var bound :BoundDetail in _bounds) {
            _numberBox.addChild(bound.createBox());
        }
        var button :Button = new Button();
        button.label = "+";
        button.addEventListener(FlexEvent.BUTTON_DOWN, addBound);
        _numberBox.addChild(button);
    }

    protected function addBound (event :FlexEvent) :void
    {
        var bound :BoundDetail = new BoundDetail();
        _bounds.push(bound);
        _numberBox.addChild(bound.createBox());
    }

    protected function modeClicked (event :ItemClickEvent) :void
    {
        if (event.label == NUMBER_MODE && _mouseBox.parent == _topBox) {
            _topBox.removeChild(_mouseBox);
            updateNumberBox();
            _topBox.addChild(_numberBox);
            _editSprite.setNodeMoveLayer(_nodeMoveLayer = null);
        } else if (event.label == MOUSE_MODE && _numberBox.parent == _topBox) {
            _topBox.removeChild(_numberBox);
            _topBox.addChild(_mouseBox);
            var piece :Piece = _pieceDetails.getCurrentPiece();
            _editSprite.setNodeMoveLayer(
                _nodeMoveLayer = new NodeMoveLayer(this, piece.width, piece.height));
            for each (var bound :BoundDetail in _bounds) {
                _nodeMoveLayer.addBoundMarker(bound.getPosition(), bound.getColor());
            }
        } else {
            log.warning("mode change borked [" + event.label + ", " + _mouseBox.parent + ", " + 
                _numberBox.parent + "]");
        }
    }

    protected var _bounds :Array = new Array();
    protected var _topBox :VBox;
    protected var _numberBox :VBox;
    protected var _mouseBox :VBox;
    protected var _mouseModeLabel :Text;
    protected var _editSprite :PieceEditSprite;
    protected var _pieceDetails :PieceEditDetails;
    protected var _nodeMoveLayer :NodeMoveLayer;

    protected static const NUMBER_MODE :String = "Number Mode";
    protected static const MOUSE_MODE :String = "Mouse Mode";
    protected static const EDIT_MODE_LABEL :String = 
        "Enter Add mode by clicking in the edit area and holding the 'a' key";
    protected static const ADD_MODE_LABEL :String = 
         "Currently in Add mode - release the 'a' key to edit nodes";

    private static const log :Log = Log.getLog(BoundsDetail);
}
}
