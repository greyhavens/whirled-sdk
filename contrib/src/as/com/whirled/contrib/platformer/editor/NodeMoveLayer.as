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
        var selectedDisplay :Sprite = new Sprite();
        addChild(selectedDisplay);
        _selectedGraphics = selectedDisplay.graphics;
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

        var draggingBound :Boolean = _mouseDown && _mouseBound != null;

        var distance :Number = Point.distance(
            new Point(mouseX - Metrics.TILE_SIZE, mouseY - Metrics.TILE_SIZE), 
            new Point(closestNode.x * Metrics.TILE_SIZE, closestNode.y * Metrics.TILE_SIZE));
        if (!draggingBound && distance > (HIGHLIGHT_RADIUS / scaleX) * 1.5) {
            _currentNode = null;
            _highlightGraphics.clear();
            return;
        }

        if (_currentNode != null && closestNode.equals(_currentNode)) {
            return;
        }
            
        _highlightGraphics.clear();
        _currentNode = closestNode;
        if (draggingBound) {
            var newPos :Point = new Point(MathUtil.clamp(_currentNode.x, 0, _maxX),
                MathUtil.clamp(_currentNode.y, 0, _maxY));
            if (!_mouseBound.pos.equals(newPos)) {
                _boundsDetail.boundMoved(_mouseBound.pos, newPos.clone());
                _mouseBound.pos = newPos;
            }
            markNode(_highlightGraphics, _currentNode, BOUND_MARKER_RADIUS, _mouseBound.color);
            markNode(_highlightGraphics, _currentNode, HIGHLIGHT_RADIUS, SELECTED_COLOR);

        } else if (!_mouseDown) {
            _mouseBound = findBoundOnNode();
            (parent as Sprite).buttonMode = _mouseBound != null;
            if (_mouseBound != null) {
                markNode(_highlightGraphics, _mouseBound.pos, HIGHLIGHT_RADIUS, MOUSE_BOUND_COLOR);
            }
        }
    }

    public function mouseDown (down :Boolean) :void
    {
        regenerateBounds();

        if (_mouseBound == null) {
            return;
        }

        if (down) {
            markNode(_highlightGraphics, _mouseBound.pos, BOUND_MARKER_RADIUS, _mouseBound.color);

        } else {
            _boundsDetail.nodeSelected((_selectedBound = _mouseBound).pos);
            _selectedGraphics.clear();
            markNode(_selectedGraphics, _selectedBound.pos, HIGHLIGHT_RADIUS, SELECTED_COLOR);
        }
    }

    public function mouseOut () :void
    {
        mouseDown(false);
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

    public function setBoundColor (position :Point, markerColor :uint) :void
    {
        var bound :Object = findBoundOnNode(position); 
        if (bound == null) {
            log.debug("bound not found to change color on [" + position + "]");
            return;
        }

        bound.color = markerColor;
        regenerateBounds();
    }

    public function removeBound (position :Point) :void 
    {
        var idx :int = findBoundIndex(position);
        if (idx < 0) {
            log.debug("bound not found to remove [" + position + "]");
            return;
        }

        if (_bounds[idx] == _selectedBound) {
            _boundsDetail.nodeSelected(null);
            _selectedBound = null;
            _selectedGraphics.clear();
        }
        if (_bounds[idx] == _mouseBound) {
            _mouseBound = null;
            _highlightGraphics.clear();
        }
        _bounds.splice(idx, 1);
        regenerateBounds();
    }

    protected function regenerateBounds () :void
    {
        var includeCurrent :Boolean = !(_mouseDown && _mouseBound != null);
        _boundGraphics.clear();
        for each (var bound :Object in _bounds) {
            if (includeCurrent || bound != _mouseBound) {
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

    protected function findBoundOnNode (node :Point = null) :Object
    {
        var idx :int = findBoundIndex(node);
        return idx < 0 ? null : _bounds[idx];
    }

    protected function findBoundIndex (node :Point = null) :int
    {
        node = node == null ? _currentNode : node;
        for (var ii :int = 0; ii < _bounds.length; ii++) {
            if (_bounds[ii].pos.equals(node)) {
                return ii;
            }
        }
        return -1;
    }

    protected var _currentNode :Point;
    protected var _mouseBound :Object;
    protected var _bounds :Array = [];
    protected var _mouseDown :Boolean = false;
    protected var _boundsDetail :BoundsDetail;
    protected var _maxX :int;
    protected var _maxY :int;
    protected var _selectedBound :Object;
    protected var _highlightGraphics :Graphics;
    protected var _boundGraphics :Graphics;
    protected var _selectedGraphics :Graphics;

    protected static const LINE_WEIGHT :int = 2;
    protected static const BOUND_MARKER_RADIUS :int = 3;
    protected static const HIGHLIGHT_RADIUS :int = 5;
    protected static const SELECTED_COLOR :int = 0xDD00DD;
    protected static const MOUSE_BOUND_COLOR :int = 0x000000;

    private static const log :Log = Log.getLog(NodeMoveLayer);
}
}
