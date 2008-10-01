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
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.Event;

import com.whirled.contrib.platformer.piece.Spawner;
import com.whirled.contrib.platformer.display.Metrics;

public class SpawnerSprite extends DynamicSprite
{
    public static const IDLE :String = "idle";
    public static const SPAWN :String = "spawn";
    public static const DEATH :String = "death";
    public static const DEAD :String = "dead";

    public function SpawnerSprite (s :Spawner, disp :DisplayObject = null)
    {
        _spawner = s;
        super(s, disp);
        if (_disp != null) {
            addChild(_disp);
            update(0);
        }
    }

    override public function update (delta :Number) :void
    {
        super.update(delta);
        if (_disp == null) {
            return;
        }
        if (_state == DEAD || _state == DEATH) {
            // do nothing;
        } else if (!_spawner.shouldSpawn()) {
            changeState(DEATH);
            var node :Sprite = new Sprite;
            node.x = _spawner.width/2 * Metrics.TILE_SIZE;
            (_disp as DisplayObjectContainer).addChild(node);
            generateParticleEffect(_spawner.deathEffect, node);
            _state = DEAD;
        } else if (_spawner.spawning) {
            changeState(SPAWN);
        } else if (_state == SPAWN) {
            _state = IDLE;
        } else {
            changeState(IDLE);
        }
        if (_hitLeft <= 0 && _spawner.wasHit && stage != null) {
            showHit();
        }
    }

    protected var _spawner :Spawner;
}
}
