//
// $Id$

package com.whirled.contrib.platformer.editor {

import flash.display.Sprite;

import flash.events.Event;
import flash.events.MouseEvent;

import flash.utils.ByteArray;

import com.whirled.contrib.platformer.board.Board;

import com.whirled.contrib.platformer.display.Metrics;
import com.whirled.contrib.platformer.piece.Piece;
import com.whirled.contrib.platformer.piece.PieceFactory;

import mx.core.Container;
import mx.core.FlexSprite;
import mx.containers.Canvas;
import mx.controls.Label;

import com.threerings.flex.FlexWrapper;

public class PieceEditView extends Canvas
{
    /**
     * In addition to requiring valid XML, the PieceSpriteFactory should have been initialized 
     * before this view is created.
     */
    public function PieceEditView (container :Container, pieces :XML)
    {
        Metrics.init(700, 500, 50);
        _container = container;
        _pfac = new PieceFactory(pieces);
        _editSprite = new PieceEditSprite();
        _editDetails = new PieceEditDetails(_pfac);
        _editSelector = new PieceSelector(_pfac);
        _editCoords = new Label();
        width = 910;
        height = 700;
        _pfac.addEventListener(PieceFactory.PIECE_UPDATED, pieceUpdated);
        _pfac.addEventListener(PieceFactory.PIECE_REMOVED, pieceRemoved);
        _editSprite.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);

        addChild(new FlexWrapper(_editSprite));
        _editDetails.x = Metrics.DISPLAY_WIDTH;
        addChild(_editDetails);
        _editSelector.y = Metrics.DISPLAY_HEIGHT;
        addChild(_editSelector);
        _editSelector.addEventListener(Event.CHANGE, pieceSelected);
        addChild(_editCoords);
        _editCoords.y = Metrics.DISPLAY_HEIGHT;
        _editCoords.x = 410;
        _editCoords.text = "Coords (0, 0)";
    }

    public function getXML () :String
    {
        return _pfac.toXML();
    }

    protected function pieceSelected (event :Event) :void
    {
        setPiece(_editSelector.getSelectedPiece());
    }

    protected function pieceUpdated (type :String, xmlDef :XML) :void
    {
        setPiece(type);
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
        _editCoords.text = "Coords (" + (_editSprite.getMouseX() - 1) + ", " +
                (_editSprite.getMouseY() - 1) + ")";
    }

    protected var _editSprite :PieceEditSprite;
    protected var _editDetails :PieceEditDetails;
    protected var _editSelector :PieceSelector;
    protected var _editCoords :Label;
    protected var _pfac :PieceFactory;

    protected var _container :Container;
}
}
