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

import flash.display.Shape;

import flash.events.MouseEvent;

import com.whirled.contrib.platformer.display.Metrics;
import com.whirled.contrib.platformer.display.PieceSprite;
import com.whirled.contrib.platformer.piece.Piece;

/**
 * A piece sprite that contains special handling for use in the editor.
 */
public class EditorPieceSprite extends EditorSprite
{
    public function EditorPieceSprite (ps :PieceSprite, es :BoardEditSprite)
    {
        super(ps, es);

        _piece = ps.getPiece();
        name = _piece.id.toString();
    }

    override public function getTileX () :Number
    {
        return _piece.x;
    }

    override public function getTileY () :Number
    {
        return _piece.y;
    }

    override public function getTileWidth () :Number
    {
        return _piece.width;
    }

    override public function getTileHeight () :Number
    {
        return _piece.height;
    }

    override public function mouseMove (newX :int, newY :int) :void
    {
        if (!isNaN(_startX)) {
            _piece.x = Math.max(0, newX - _startX);
            _piece.y = Math.max(0, newY - _startY);
            update();
        }
    }

    protected var _piece :Piece;
}
}
