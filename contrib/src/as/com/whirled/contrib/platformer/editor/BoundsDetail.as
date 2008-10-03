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

        // TODO
        _mouseBox = new VBox();

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
        log.debug("nodeSelected [" + pos + "]");
    }

    public function boundMoved (oldPos :Point, newPos :Point) :void
    {
        for each (var bound :BoundDetail in _bounds) {
            if (bound.getPosition().equals(oldPos)) {
                bound.setPosition(newPos);
                _pieceDetails.updatePiece();
                return;
            }
        }
        log.warning("bound not found to move [" + oldPos + ", " + newPos + "]");
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
            log.debug("mode change borked [" + event.label + ", " + _mouseBox.parent + ", " + 
                _numberBox.parent + "]");
        }
    }

    protected var _bounds :Array = new Array();
    protected var _topBox :VBox;
    protected var _numberBox :VBox;
    protected var _mouseBox :VBox;
    protected var _editSprite :PieceEditSprite;
    protected var _pieceDetails :PieceEditDetails;
    protected var _nodeMoveLayer :NodeMoveLayer;

    protected static const NUMBER_MODE :String = "Number Mode";
    protected static const MOUSE_MODE :String = "Mouse Mode";

    private static const log :Log = Log.getLog(BoundsDetail);
}
}
