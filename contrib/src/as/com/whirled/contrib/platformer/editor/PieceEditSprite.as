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

import flash.events.MouseEvent;

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

    override protected function initDisplay () :void
    {
        addChild(_layers[PIECE_LAYER] = new EditorSpriteLayer());
        // TODO: sort out the y-positioning bug and re-enable this
        //addChild(_layers[NODE_MOVE_LAYER] = new NodeMoveLayer());
        _layers[NODE_MOVE_LAYER] = new NodeMoveLayer();
        _layers[NODE_MOVE_LAYER].alpha = 0.5;

        super.initDisplay();
    }

    override protected function get GRID_LAYER () :int
    {
        return PIECE_GRID_LAYER;
    }

    override protected function mouseDownHandler (event :MouseEvent) :void
    {
        super.mouseDownHandler(event);
    }

    override protected function mouseUpHandler (event :MouseEvent) :void
    {
        super.mouseUpHandler(event);
    }

    override protected function mouseOverHandler (event :MouseEvent) :void
    {
        super.mouseOverHandler(event);
    }

    override protected function mouseOutHandler (event: MouseEvent) :void
    {
        super.mouseOutHandler(event);

        _layers[NODE_MOVE_LAYER].clearDisplay();
    }

    override protected function mouseMoveHandler (event :MouseEvent) :void
    {
        super.mouseMoveHandler(event);

        _layers[NODE_MOVE_LAYER].mousePositionUpdated(getMouseX(), getMouseY());
    }

    protected static const PIECE_GRID_LAYER :int = 0;
    protected static const PIECE_LAYER :int = 1;
    protected static const NODE_MOVE_LAYER :int = 2;
}
}
