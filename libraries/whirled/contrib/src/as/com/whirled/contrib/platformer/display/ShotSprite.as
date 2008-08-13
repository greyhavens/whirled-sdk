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

import com.whirled.contrib.platformer.piece.Shot;

public class ShotSprite extends DynamicSprite
{
    public function ShotSprite (s :Shot, disp :DisplayObject = null)
    {
        super(s, disp);
        _shot = s;
        if (_disp != null) {
            _disp.visible = false;
            addChild(_disp);
            update(0);
            this.rotation = Math.atan2(-_shot.dy, _shot.dx) * 180 / Math.PI + 90;
        }
    }

    public override function update (delta :Number) :void
    {
        super.update(delta);
        if (_disp != null && !_disp.visible) {
            _alive += delta;
            if (_alive > TIME_TO_LIVE) {
                _disp.visible = true;
            }
        }
        if (_shot.hit) {
            generateParticleEffect(_shot.hitEffect, this);
        } else if (_shot.ttl <= 0 && _disp != null) {
            rotation += 180;
            generateParticleEffect(_shot.missEffect, this);
        }
    }

    protected var _shot :Shot;
    protected var _alive :Number = 0;

    protected static const TIME_TO_LIVE :Number = 0.05;
}
}
