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

import flash.geom.Point;

import com.threerings.util.Log;

import com.whirled.contrib.platformer.display.Layer;
import com.whirled.contrib.platformer.display.Metrics;

public class NodeMoveLayer extends Layer
{
    public function NodeMoveLayer ()
    {
        mouseEnabled = false;
        mouseChildren = false;
    }

    public function mousePositionUpdated (mouseX :Number, mouseY :Number) :void
    {
        var closestNode :Point = new Point(
            Math.round(mouseX / Metrics.TILE_SIZE), Math.round(mouseY / Metrics.TILE_SIZE));
        if (closestNode.x < 0 || closestNode.y < 0) {
            clearDisplay();
            return;
        }

        var distance :Number = Point.distance(new Point(mouseX, mouseY), 
            new Point(closestNode.x * Metrics.TILE_SIZE, closestNode.y * Metrics.TILE_SIZE));
        if (distance > (DISPLAY_RADIUS / scaleX) * 1.5) {
            clearDisplay();
            return;
        }

        if (_currentNode != null && closestNode.equals(_currentNode)) {
            return;
        }
            
        clearDisplay();
        _currentNode = closestNode;
        createDisplay(); 
    }

    public function clearDisplay () :void
    {
        _currentNode = null;
        graphics.clear();
    }

    override public function update (nX :Number, nY :Number, scale :Number = 1) :void
    {
        scaleX = 1 / scale;
        scaleY = 1 / scale;
        x = Math.floor(-nX);
        y = Math.floor(-nY);
    }

    protected function createDisplay () :void
    {
        if (_currentNode == null) {
            log.warning("asked to create display with a null node");
            return;
        }

        graphics.lineStyle(2, SELECTION_COLOR);
        graphics.drawCircle(_currentNode.x * Metrics.TILE_SIZE,
            Metrics.DISPLAY_HEIGHT - _currentNode.y * Metrics.TILE_SIZE, DISPLAY_RADIUS / scaleX);
    }

    protected var _currentNode :Point;

    protected static const DISPLAY_RADIUS :int = 5;
    protected static const SELECTION_COLOR :int = 0x880000;

    private static const log :Log = Log.getLog(NodeMoveLayer);
}
}
