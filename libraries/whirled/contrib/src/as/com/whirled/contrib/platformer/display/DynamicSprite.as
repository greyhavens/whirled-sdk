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

package com.whirled.contrib.platformer.display {

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

import flash.events.Event;

import flash.filters.ColorMatrixFilter;

import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Transform;

import com.whirled.contrib.ColorMatrix;
import com.whirled.contrib.platformer.piece.Dynamic;

public class DynamicSprite extends Sprite
{
    public function DynamicSprite (dy :Dynamic, disp :DisplayObject = null)
    {
        _dynamic = dy;
        _disp = disp;
        addEventListener(Event.ADDED, handleAdded);
        addEventListener(Event.REMOVED, handleRemoved);
    }

    public function getDynamic () :Dynamic
    {
        return _dynamic;
    }

    public function update (delta :Number) :void
    {
        this.x = _dynamic.x * Metrics.TILE_SIZE;
        this.y = -_dynamic.y * Metrics.TILE_SIZE;
    }

    public function setParticleCallback (callback :Function) :void
    {
        _particleCallback = callback;
    }

    public function setStatic (s :Boolean) :void
    {
        _static = s;
    }

    protected function handleAdded (event :Event) :void
    {
        if (event.target != this) {
            return;
        }
        onAdded();
    }

    protected function onAdded () :void
    {
        playState();
    }

    protected function handleRemoved (event :Event) :void
    {
        if (event.target != this) {
            return;
        }
        onRemoved();
    }

    protected function onRemoved () :void
    {
        if (_disp is MovieClip) {
            (_disp as MovieClip).stop();
        }
    }

    protected function changeState (newState :String) :void
    {
        if (_state != newState) {
            _state = newState;
            if (stage != null) {
                playState();
            }
        }
    }

    protected function playState () :void
    {
        if (_disp is MovieClip) {
            if (_static) {
                (_disp as MovieClip).gotoAndStop(1);
            } else {
                //trace("goto and play: " + _state);
                (_disp as MovieClip).gotoAndPlay(_state);
            }
        }
    }

    protected function generateParticleEffect (
            name :String, node :DisplayObject, back :Boolean = false,
            recolor :String = null, filter :ColorMatrixFilter = null) :void
    {
        if (_particleCallback != null && stage != null && node != null && name != null) {
            var disp :DisplayObject = PieceSpriteFactory.instantiateClip(name);
            if (disp == null) {
                return;
            }
            var pt :Point = node.localToGlobal(new Point());
            var opt :Point = node.localToGlobal(new Point(0, 0));
            var apt :Point = node.localToGlobal(new Point(0, -1));
            apt = apt.subtract(opt);
            apt.normalize(1);
            disp.rotation = -90 + (Math.atan2(apt.y, apt.x) - Math.atan2(0, -1)) * 180 / Math.PI;
            if (recolor != null) {
                recolorNodes(recolor, disp, filter);
            }
            _particleCallback(disp, pt, back);
        }
    }

    protected function generateAttachedEffect (name :String, node :DisplayObjectContainer) :void
    {
        if (stage == null || name == null || node == null) {
            return;
        }
        var disp :DisplayObject = PieceSpriteFactory.instantiateClip(name);
        if (disp == null) {
            return;
        }
        disp.addEventListener(Event.COMPLETE, function (event :Event) :void {
            if (event.target == disp) {
                event.stopPropagation();
                disp.parent.removeChild(disp);
                trace("removing generated attached effect");
            }
        });
        node.addChild(disp);
    }

    protected function recolorNodesToColor (
        node :String, disp :DisplayObject, color :int) :ColorMatrixFilter
    {
        var matrix :ColorMatrix = new ColorMatrix();
        matrix.colorize(color);
        var filter :ColorMatrixFilter = matrix.createFilter();
        recolorNodes(node, disp, filter);
        return filter;
    }

    protected function recolorNodes (
        node :String, disp :DisplayObject, filter :ColorMatrixFilter) :void
    {
        if (disp.name == node) {
            var filters :Array = disp.filters;
            if (filters == null) {
                disp.filters = [filter];
            } else {
                filters.push(filter);
                disp.filters = filters;
            }
        }
        if (disp is DisplayObjectContainer) {
            var cont :DisplayObjectContainer = disp as DisplayObjectContainer;
            for (var ii :int = 0; ii < cont.numChildren; ii++) {
                recolorNodes(node, cont.getChildAt(ii), filter);
            }
        }
    }

    protected var _state :String = "";
    protected var _dynamic :Dynamic;
    protected var _disp :DisplayObject;
    protected var _particleCallback :Function;
    protected var _static :Boolean;
}
}
