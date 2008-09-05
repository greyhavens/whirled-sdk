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

        super.initDisplay();
    }

    override protected function get GRID_LAYER () :int
    {
        return PIECE_GRID_LAYER;
    }

    protected static const PIECE_GRID_LAYER :int = 0;
    protected static const PIECE_LAYER :int = 1;
}
}
