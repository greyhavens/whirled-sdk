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
import com.whirled.contrib.platformer.util.Metrics;

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
            if ((_actor.orient & Actor.ORIENT_RIGHT) == 0) {
                _disp.scaleX = -1;
            }
            update(0);
        }
    }

    public function getActor () :Actor
    {
        return _actor;
    }

    override public function shutdown () :void
    {
        super.shutdown();
        if (_disp != null) {
            _disp.removeEventListener(Event.COMPLETE, actionComplete);
        }
    }

    override public function update (delta :Number) :void
    {
        super.update(delta);
        _oldDx = _actor.dx;
        _oldDy = _actor.dy;
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

    override protected function changeState (newState :String) :void
    {
        if (_state != newState) {
            if (_state == TURN) {
                _disp.scaleX *= -1;
            }
        }
        super.changeState(newState);
    }

    protected var _actor :Actor;

    protected var _oldDx :Number = 0;
    protected var _oldDy :Number = 0;
}
}
