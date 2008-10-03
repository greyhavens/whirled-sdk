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

import flash.display.Sprite;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.system.System;

import flash.utils.ByteArray;

import mx.core.Container;
import mx.core.FlexSprite;
import mx.core.UIComponent;
import mx.containers.Canvas;
import mx.containers.HBox;
import mx.containers.VBox;
import mx.controls.Button;
import mx.controls.HSlider;
import mx.controls.Label;
import mx.events.SliderEvent;

import com.whirled.contrib.platformer.display.Metrics;
import com.whirled.contrib.platformer.piece.Piece;
import com.whirled.contrib.platformer.piece.PieceFactory;

public class PieceEditView extends Canvas
{
    /**
     * In addition to requiring valid XML, the PieceSpriteFactory should have been initialized
     * before this view is created.
     *
     * Also, it is required that Metrics.init() be called before creating this view.
     */
    public function PieceEditView (pfac :PieceFactory)
    {
        _pfac = pfac;
        _editSprite = new PieceEditSprite();
        _editDetails = new PieceEditDetails(_pfac, _editSprite);
        _editSelector = new PieceSelector(_pfac);
        _editCoords = new Label();
        percentWidth = 100;
        percentHeight = 100;
        _pfac.addEventListener(PieceFactory.PIECE_UPDATED, pieceUpdated);
        _pfac.addEventListener(PieceFactory.PIECE_REMOVED, pieceRemoved);
        _editSprite.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);

        _editDetails.setStyle("right", 0);
        _editDetails.setStyle("top", 0);
        _editDetails.setStyle("bottom", 0);
        _editDetails.setStyle("backgroundColor", "white");
        addChild(_editDetails);

        var bottomBox :HBox = new HBox();
        bottomBox.setStyle("left", 0);
        bottomBox.setStyle("right", _editDetails.width);
        bottomBox.setStyle("bottom", 0);
        addChild(bottomBox);
        bottomBox.addChild(_editSelector);
        _editSelector.addEventListener(Event.CHANGE, pieceSelected);

        var controlsBox :VBox = new VBox();
        _editCoords.text = "Coords (0, 0)";
        controlsBox.addChild(_editCoords);
        var row :HBox = new HBox();
        var label :Label = new Label();
        label.text = "Scale: ";
        row.addChild(label);
        var scaleSlider :HSlider = new HSlider();
        scaleSlider.liveDragging = true;
        scaleSlider.showDataTip = false;
        scaleSlider.maximum = EditSprite.MAX_SCALE;
        scaleSlider.minimum = EditSprite.MIN_SCALE;
        scaleSlider.tickInterval = 1;
        scaleSlider.snapInterval = 1;
        _editSprite.setScale(scaleSlider.value = 0);
        scaleSlider.addEventListener(SliderEvent.CHANGE, function (...ignored) :void {
            _editSprite.setScale(scaleSlider.value);
        });
        row.addChild(scaleSlider);
        row.addChild(EditView.makeButton("grid", function () :void {
            _editSprite.toggleGrid();
        }));
        controlsBox.addChild(row);
        controlsBox.addChild(EditView.makeButton("Copy to Clipboard", function () :void {
            System.setClipboard(getXML().toXMLString());
        }));
        bottomBox.addChild(controlsBox);

        var component :UIComponent = _editSprite.getUIComponent();
        component.setStyle("top", 0);
        component.setStyle("left", 0);
        component.setStyle("right", _editDetails.width);
        // bottomBox needs a frame to represent its real height
        callLater(function () :void { component.setStyle("bottom", bottomBox.height); });
        addChildAt(component, 0);
    }

    public function getXML () :XML
    {
        return _pfac.toXML();
    }

    protected function pieceSelected (event :Event) :void
    {
        setPiece(_editSelector.getSelectedPiece());
    }

    protected function pieceUpdated (type :String, xmlDef :XML) :void
    {
        var pxml :XML = <piece/>;
        pxml.@type = type;
        pxml.@x = 1;
        pxml.@y = 1;
        _editSprite.setPiece(_pfac.getPiece(pxml));
    }

    protected function pieceRemoved (type :String, xmlDef :XML) :void
    {
        setPiece(null);
    }

    protected function setPiece (type :String) :void
    {
        if (type == null) {
            _editSprite.setPiece(null);
            _editDetails.setPiece(type);
        } else {
            var pxml :XML = <piece/>;
            pxml.@type = type;
            pxml.@x = 1;
            pxml.@y = 1;
            var p :Piece = _pfac.getPiece(pxml);
            _editSprite.setPiece(p);
            _editDetails.setPiece(type, p);
        }
    }

    protected function mouseMoveHandler (event :MouseEvent) :void
    {
        _editCoords.text = "Coords (" + (_editSprite.getMouseTileX() - 1) + ", " +
                (_editSprite.getMouseTileY() - 1) + ")";
    }

    protected var _editSprite :PieceEditSprite;
    protected var _editDetails :PieceEditDetails;
    protected var _editSelector :PieceSelector;
    protected var _editCoords :Label;
    protected var _pfac :PieceFactory;
}
}
