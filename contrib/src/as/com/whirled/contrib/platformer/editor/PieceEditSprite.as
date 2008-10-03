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

import flash.display.DisplayObject;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.KeyboardEvent;

import flash.events.MouseEvent;

import com.whirled.contrib.platformer.display.Layer;
import com.whirled.contrib.platformer.display.PieceSprite;
import com.whirled.contrib.platformer.display.PieceSpriteFactory;

import com.whirled.contrib.platformer.piece.Piece;

public class PieceEditSprite extends EditSprite
{
    public function PieceEditSprite ()
    {
        // we default to normal scale here
        _scale = 1;
        initDisplay();

        addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
        addEventListener(KeyboardEvent.KEY_UP, keyUp);
    }

    public function setPiece (p :Piece) :void
    {
        _layers[PIECE_LAYER].clear();
        if (p != null) {
            var ps :PieceSprite = PieceSpriteFactory.getPieceSprite(p);
            ps.showDetails(true);
            _layers[PIECE_LAYER].addEditorSprite(new EditorPieceSprite(ps, null), "");
        }
    }

    public function setNodeMoveLayer (sprite :Sprite) :void
    {
        if (_layers[NODE_MOVE_LAYER] != null) {
            removeChild(_layers[NODE_MOVE_LAYER]);
        }

        _layers[NODE_MOVE_LAYER] = sprite;

        if (sprite != null) {
            addChildAt(sprite, getChildIndex(_layers[PIECE_LAYER]) + 1);
            (_layers[NODE_MOVE_LAYER] as Layer).update(_bX / _scale, _bY / _scale, _scale);
        }
    }

    override protected function initDisplay () :void
    {
        addChild(_layers[PIECE_LAYER] = new EditorSpriteLayer());
        _layers[PIECE_LAYER].mouseEnabled = false;
        _layers[PIECE_LAYER].mouseChildren = false;

        super.initDisplay();
    }

    override protected function get GRID_LAYER () :int
    {
        return PIECE_GRID_LAYER;
    }

    override protected function mouseDownHandler (event :MouseEvent) :void
    {
        super.mouseDownHandler(event);

        if (_layers[NODE_MOVE_LAYER] != null) {
            (_layers[NODE_MOVE_LAYER] as NodeMoveLayer).mouseDown(true);
        }
    }

    override protected function mouseUpHandler (event :MouseEvent) :void
    {
        super.mouseUpHandler(event);

        if (_layers[NODE_MOVE_LAYER] != null) {
            (_layers[NODE_MOVE_LAYER] as NodeMoveLayer).mouseDown(false);
        }
    }

    override protected function mouseOutHandler (event: MouseEvent) :void
    {
        super.mouseOutHandler(event);

        if (_layers[NODE_MOVE_LAYER] != null) {
            _layers[NODE_MOVE_LAYER].mouseOut();
        }
    }

    override protected function mouseMoveHandler (event :MouseEvent) :void
    {
        super.mouseMoveHandler(event);

        if (_layers[NODE_MOVE_LAYER] != null) {
            (_layers[NODE_MOVE_LAYER] as NodeMoveLayer).mousePositionUpdated(
                getMouseX(), getMouseY());
        }
    }

    protected function keyDown (event :KeyboardEvent) :void
    {
        if (event.charCode == PIECE_ADD_KEY && !_addKeyDown) { 
            _addKeyDown = true;
            if (_layers[NODE_MOVE_LAYER] != null) {
                (_layers[NODE_MOVE_LAYER] as NodeMoveLayer).setMode(NodeMoveLayer.ADD_MODE); 
            }
        }
    }

    protected function keyUp (event :KeyboardEvent) :void
    {
        if (event.charCode == PIECE_ADD_KEY && _addKeyDown) {
            _addKeyDown = false;
            if (_layers[NODE_MOVE_LAYER] != null) {
                (_layers[NODE_MOVE_LAYER] as NodeMoveLayer).setMode(NodeMoveLayer.EDIT_MODE);
            }
        }
    }

    protected var _addKeyDown :Boolean = false;

    protected static const PIECE_GRID_LAYER :int = 0;
    protected static const PIECE_LAYER :int = 1;
    protected static const NODE_MOVE_LAYER :int = 2;

    protected static const PIECE_ADD_KEY :int = "a".charCodeAt(0);
}
}
