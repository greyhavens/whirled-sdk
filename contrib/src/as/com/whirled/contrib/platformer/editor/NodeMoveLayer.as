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

import flash.display.BlendMode;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Point;

import com.threerings.util.Log;

import com.threerings.flash.MathUtil;

import com.whirled.contrib.platformer.display.Layer;
import com.whirled.contrib.platformer.display.Metrics;

public class NodeMoveLayer extends Layer
{
    public function NodeMoveLayer (detail :BoundsDetail, pieceWidth :int, pieceHeight :int)
    {
        _boundsDetail = detail;
        _maxX = pieceWidth;
        _maxY = pieceHeight;
        mouseEnabled = false;
        mouseChildren = false;
        alpha = 0.5;
        var boundDisplay :Sprite = new Sprite();
        addChild(boundDisplay);
        _boundGraphics = boundDisplay.graphics;
        var highlightDisplay :Sprite = new Sprite();
        highlightDisplay.blendMode = BlendMode.INVERT;
        addChild(highlightDisplay);
        _highlightGraphics = highlightDisplay.graphics;
    }

    public function mousePositionUpdated (mouseX :Number, mouseY :Number) :void
    {
        var closestNode :Point = new Point(
            Math.round(mouseX / Metrics.TILE_SIZE), Math.round(mouseY / Metrics.TILE_SIZE));
        closestNode.x--;
        closestNode.y--;
        if (closestNode.x < 0 || closestNode.y < 0) {
            _currentNode = null;
            _highlightGraphics.clear();
            return;
        }

        var distance :Number = Point.distance(
            new Point(mouseX - Metrics.TILE_SIZE, mouseY - Metrics.TILE_SIZE), 
            new Point(closestNode.x * Metrics.TILE_SIZE, closestNode.y * Metrics.TILE_SIZE));
        if (distance > (HIGHLIGHT_RADIUS / scaleX) * 1.5) {
            _currentNode = null;
            _highlightGraphics.clear();
            return;
        }

        if (_currentNode != null && closestNode.equals(_currentNode)) {
            return;
        }
            
        _highlightGraphics.clear();
        _currentNode = closestNode;
        if (_mouseDown && _currentBound != null) {
            var newPos :Point = new Point(MathUtil.clamp(_currentNode.x, 0, _maxX),
                MathUtil.clamp(_currentNode.y, 0, _maxY));
            if (!_currentBound.pos.equals(newPos)) {
                _boundsDetail.boundMoved(_currentBound.pos, newPos.clone());
                _currentBound.pos = newPos;
            }
            markNode(_highlightGraphics, _currentNode, BOUND_MARKER_RADIUS, _currentBound.color);
            markNode(_highlightGraphics, _currentNode, HIGHLIGHT_RADIUS, HIGHLIGHT_COLOR);

        } else if (!_mouseDown) {
            _currentBound = findBoundOnNode();
            (parent as Sprite).buttonMode = _currentBound != null;
            if (_currentBound != null) {
                markNode(_highlightGraphics, _currentNode, HIGHLIGHT_RADIUS, HIGHLIGHT_COLOR);
            }
        }
    }

    public function mouseDown (down :Boolean) :void
    {
        regenerateBounds(!(_mouseDown = down));
    }

    public function mouseOut () :void
    {
        mouseDown(false);
        _currentNode = null;
        _highlightGraphics.clear();
    }

    override public function update (nX :Number, nY :Number, scale :Number = 1) :void
    {
        scaleX = 1 / scale;
        scaleY = 1 / scale;
        x = Math.floor(-nX);
        y = Math.floor(-nY);

        _boundGraphics.clear();
        for each (var bound :Object in _bounds) {
            markNode(_boundGraphics, bound.pos, BOUND_MARKER_RADIUS, bound.color);
        }
    }

    public function addBoundMarker (position :Point, markerColor :uint) :void
    {
        _bounds.push({pos: position, color: markerColor});
        markNode(_boundGraphics, position, BOUND_MARKER_RADIUS, markerColor); 
    }

    protected function regenerateBounds (includeCurrent :Boolean = true) :void
    {
        _boundGraphics.clear();
        for each (var bound :Object in _bounds) {
            if (includeCurrent || bound != _currentBound) {
                markNode(_boundGraphics, bound.pos, BOUND_MARKER_RADIUS, bound.color);
            }
        }
    }

    protected function markNode (gfx :Graphics, position :Point, radius :int, 
        color :uint) :void
    {
        var xPos :Number = (position.x + 1) * Metrics.TILE_SIZE;
        var yPos :Number = Metrics.DISPLAY_HEIGHT / scaleX - (position.y + 1) * Metrics.TILE_SIZE;
        gfx.lineStyle(LINE_WEIGHT / scaleX, color);
        gfx.drawCircle(xPos, yPos, radius / scaleX);
    }

    protected function findBoundOnNode () :Object
    {
        for each (var bound :Object in _bounds) {
            if (bound.pos.equals(_currentNode)) {
                return bound;
            }
        }
        return null;
    }

    protected var _currentNode :Point;
    protected var _currentBound :Object;
    protected var _bounds :Array = [];
    protected var _boundGraphics :Graphics;
    protected var _highlightGraphics :Graphics;
    protected var _mouseDown :Boolean = false;
    protected var _boundsDetail :BoundsDetail;
    protected var _maxX :int;
    protected var _maxY :int;

    protected static const LINE_WEIGHT :int = 2;
    protected static const BOUND_MARKER_RADIUS :int = 3;
    protected static const HIGHLIGHT_RADIUS :int = 5;
    protected static const HIGHLIGHT_COLOR :int = 0x000000;

    private static const log :Log = Log.getLog(NodeMoveLayer);
}
}
