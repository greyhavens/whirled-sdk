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

import com.whirled.contrib.platformer.display.Metrics;
import com.whirled.contrib.platformer.display.PieceSprite;
import com.whirled.contrib.platformer.display.PieceSpriteLayer;
import com.whirled.contrib.platformer.display.PieceSpriteFactory;

import com.whirled.contrib.platformer.piece.Piece;

public class PieceEditSprite extends EditSprite
{
    public function setPiece (p :Piece) :void
    {
        _pieceLayer.clear();
        if (p != null) {
            var ps :PieceSprite = PieceSpriteFactory.getPieceSprite(p);
            ps.showDetails(true);
            _pieceLayer.addPieceSprite(ps);
        }
    }

    override protected function initDisplay () :void
    {
        var masker :Shape = new Shape();
        masker.graphics.beginFill(0x000000);
        masker.graphics.drawRect(0, 0, Metrics.DISPLAY_WIDTH, Metrics.DISPLAY_HEIGHT);
        masker.graphics.endFill();
        mask = masker;
        addChild(masker);
        masker = new Shape();
        masker.graphics.beginFill(0xFFFFFF);
        masker.graphics.drawRect(0, 0, Metrics.DISPLAY_WIDTH, Metrics.DISPLAY_HEIGHT);
        masker.graphics.endFill();
        addChild(masker);
        addChild(_gridLayer = new GridLayer());
        addChild(_pieceLayer = new PieceSpriteLayer());

        super.initDisplay();
    }

    override protected function updateDisplay () :void
    {
        _gridLayer.update(_bX, _bY);
        _pieceLayer.update(_bX, _bY);
    }

    protected var _pieceLayer :PieceSpriteLayer;
    protected var _gridLayer :GridLayer;
}
}
