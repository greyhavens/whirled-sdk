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

    public override function getTileX () :Number
    {
        return _piece.x;
    }

    public override function getTileY () :Number
    {
        return _piece.y;
    }

    public override function getTileWidth () :Number
    {
        return _piece.width;
    }

    public override function getTileHeight () :Number
    {
        return _piece.height;
    }

    public override function mouseMove (newX :int, newY :int) :void
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
