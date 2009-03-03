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
import flash.display.Sprite;

import com.whirled.contrib.platformer.piece.LaserShot;
import com.whirled.contrib.platformer.util.Effect;
import com.whirled.contrib.platformer.util.Metrics;

public class LaserShotSprite extends ShotSprite
{
    public function LaserShotSprite (ls :LaserShot, disp :DisplayObject = null)
    {
        super(ls, disp);
        _ls = ls;
        this.rotation = Math.atan2(-ls.dy, ls.dx) * 180 / Math.PI + 90;
        update(0);
    }

    override public function update (delta :Number) :void
    {
        if (_ls.hit != null && stage != null) {
            var effect :Effect = _ls.length < 1 ? _ls.wallEffect : _ls.laserEffect;
            generateEffect(effect, this, null, _ls.length);
            if (_ls.hits != null) {
                var node :Sprite = new Sprite();
                addChild(node);
                node.rotation = - this.rotation;
                for each (var dist :Number in _ls.hits) {
                    node.y = -dist * _ls.length * 24 * Metrics.TILE_SIZE;
                    generateEffect(_ls.hitEffect, node);
                    trace("generating " + _ls.hitEffect + " at " + dist);
                }
            }
            _dead = true;
        }
        super.update(delta);
    }

    protected var _ls :LaserShot;
}
}

