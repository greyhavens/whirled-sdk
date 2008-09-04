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
import flash.display.Sprite;

import flash.events.MouseEvent;

import flash.geom.Point;

import com.threerings.util.ArrayIterator;

import com.whirled.contrib.platformer.board.Board;

import com.whirled.contrib.platformer.display.Metrics;

import com.whirled.contrib.platformer.piece.Piece;

public class EditSprite extends Sprite
{
    public function EditSprite ()
    {
        addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
        addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
        addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
        addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
        addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);

        initDisplay();
    }

    public function positionView (nX :Number, nY :Number) :void
    {
        _bX = nX;
        _bY = nY;
        updateDisplay();
    }

    public function moveView (dX :Number, dY :Number) :void
    {
        _bX += dX;
        _bY += dY;
        updateDisplay();
    }

    public function getX () :int
    {
        return _bX / Metrics.TILE_SIZE;
    }

    public function getY () :int
    {
        return -_bY / Metrics.TILE_SIZE;
    }

    public function moveViewTile (dX :int, dY :int) :void
    {
        //trace("moveViewTile (" + dX + ", " + dY + ")");
        moveView(dX * Metrics.TILE_SIZE, dY * Metrics.TILE_SIZE);
    }

    public function positionViewTile (dX :int, dY :int) :void
    {
        positionView(dX * Metrics.TILE_SIZE, dY * Metrics.TILE_SIZE);
    }

    public function getMouseX () :int
    {
        return Math.floor((_bX + mouseX) / Metrics.TILE_SIZE);
    }

    public function getMouseY () :int
    {
        return Math.floor(((Metrics.DISPLAY_HEIGHT - mouseY) - _bY) / Metrics.TILE_SIZE);
    }

    protected function clearDisplay () :void
    {

    }

    protected function initDisplay () :void
    {
        positionView(0, 0);
    }

    protected function updateDisplay () :void
    {
    }

    protected function mouseDownHandler (event :MouseEvent) :void
    {
    }

    protected function mouseUpHandler (event :MouseEvent) :void
    {
        clearDrag();
    }

    protected function mouseOverHandler (event :MouseEvent) :void
    {
        if (!event.buttonDown) {
            clearDrag();
        }
    }

    protected function mouseOutHandler (event: MouseEvent) :void
    {
    }

    protected function mouseMoveHandler (event :MouseEvent) :void
    {
        var newX :int = getMouseX();
        var newY :int = getMouseY();
        if (newX != _mX || newY != _mY) {
            tileChanged(newX, newY);
            _mX = newX;
            _mY = newY;
        }
    }

    protected function tileChanged (newX :int, newY :int) :void
    {
    }

    protected function clearDrag () :void
    {
    }

    protected var _bX :int;
    protected var _bY :int;

    protected var _mX :int;
    protected var _mY :int;
}
}
