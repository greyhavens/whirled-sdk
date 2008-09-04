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

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.DisplayObjectContainer;
import flash.display.Shape;
import flash.display.Sprite;

import flash.events.Event;

import flash.filters.ColorMatrixFilter;

import com.whirled.contrib.ColorMatrix;
import com.whirled.contrib.platformer.piece.Actor;

public class ActorSprite extends DynamicSprite
{
    public static const TURN :String = "turn";

    public function ActorSprite (actor :Actor, disp :DisplayObject = null)
    {
        super(actor, disp);
        _actor = actor;
        if (_disp != null) {
            _disp.x = _actor.width / 2 * Metrics.TILE_SIZE;
            addChild(_disp);
            _disp.addEventListener(Event.COMPLETE, actionComplete);
            if (BoardSprite.SHOW_DETAILS) {
                var outline :Shape = new Shape();
                outline.graphics.lineStyle(0, 0xFF0000);
                outline.graphics.drawRect(
                        0, 0, _actor.width*Metrics.TILE_SIZE, -_actor.height*Metrics.TILE_SIZE);
                addChild(outline);
            }
            update(0);
        }
    }

    public function getActor () :Actor
    {
        return _actor;
    }

    override public function update (delta :Number) :void
    {
        super.update(delta);
        _oldDx = _actor.dx;
        _oldDy = _actor.dy;
        _wasAttached = _actor.attached != null;
        if (_hitLeft > 0) {
            _hitLeft -= delta;
            if (_hitLeft <= 0) {
                var filters :Array = _disp.filters;
                if (filters != null) {
                    // Adding a filter to a DisplayObject changes the filter, so you can't compare
                    // the filter to figure out which one it is in the array.  So we're left with
                    // maintaining an index, and hoping that the filters haven't changed so that
                    // we remove the correct one.  Thank you ActionScript.
                    filters.splice(_hitFilterIndex, 1);
                    _disp.filters = filters;
                }
            }
        }
        if (_hitLeft <= 0 && _actor.wasHit > 0 && stage != null) {
            showHit();
        }
    }

    override public function setStatic (s :Boolean) :void
    {
        var changed :Boolean = s != _static;
        super.setStatic(s);
        if (changed) {
            playState();
        }
    }

    protected function actionComplete (event :Event) :void
    {
        handleActionComplete();
    }

    protected function handleActionComplete () :void
    {
    }

    override protected function onAdded () :void
    {
        playState();
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

    override protected function onRemoved () :void
    {
        if (_disp is MovieClip) {
            (_disp as MovieClip).stop();
        }
    }

    protected function changeState (newState :String) :void
    {
        if (_state != newState) {
            if (_state == TURN) {
                _disp.scaleX *= -1;
            }
            _state = newState;
            if (stage != null) {
                playState();
            }
        }
    }

    protected function showHit () :void
    {
        if (_hitLeft <= 0) {
            _hitLeft = HIT_LENGTH;
            if (_hitFilter == null) {
                var matrix :ColorMatrix = new ColorMatrix();
                matrix.tint(0xFFE377, 0.5);
                _hitFilter = matrix.createFilter();
            }
            var filters :Array = _disp.filters;
            if (filters == null) {
                _disp.filters = [_hitFilter];
                _hitFilterIndex = 0;
            } else {
                _hitFilterIndex = filters.length;
                filters.push(_hitFilter);
                _disp.filters = filters;
            }
        }
    }

    protected function findNode (node :String, disp :DisplayObject) :DisplayObject
    {
        var ret :Array = findNodes([ node ], disp);
        return (ret == null ? null : ret[0]);
    }

    protected function findNodes (nodes :Array, disp :DisplayObject) :Array
    {
        var ret :Array;
        if (disp == null) {
            return ret;
        }
        if (nodes.indexOf(disp.name) != -1) {
            ret = new Array();
            ret.push(disp);
        }
        if (disp is DisplayObjectContainer) {
            var cont :DisplayObjectContainer = disp as DisplayObjectContainer;
            for (var ii :int = 0; ii < cont.numChildren; ii++) {
                var disps :Array = findNodes(nodes, cont.getChildAt(ii));
                if (disps != null) {
                    if (ret == null) {
                        ret = new Array();
                    }
                    ret = ret.concat(disps);
                }
            }
        }
        return ret;
    }

    protected var _state :String = "";
    protected var _actor :Actor;
    protected var _hitLeft :Number = 0;
    protected var _hitFilter :ColorMatrixFilter;
    protected var _hitFilterIndex :int;

    protected var _oldDx :Number = 0;
    protected var _oldDy :Number = 0;
    protected var _wasAttached :Boolean = false;

    protected static const HIT_LENGTH :Number = 0.1;
}
}
