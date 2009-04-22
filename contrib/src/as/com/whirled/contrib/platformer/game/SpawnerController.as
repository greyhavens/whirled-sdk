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

package com.whirled.contrib.platformer.game {

import com.whirled.contrib.platformer.PlatformerContext;
import com.whirled.contrib.platformer.board.Board;
import com.whirled.contrib.platformer.game.Collision;
import com.whirled.contrib.platformer.net.ShotMessage;
import com.whirled.contrib.platformer.net.SpawnerMessage;
import com.whirled.contrib.platformer.piece.Actor;
import com.whirled.contrib.platformer.piece.Spawner;

public class SpawnerController extends RectDynamicController
    implements ShootableController
{
    public function SpawnerController (s :Spawner, controller :GameController)
    {
        super(s, controller);
        _spawner = s;
        if (_spawner.spawns == null) {
            _spawner.spawns = new Array();
        }
    }

    override public function hasBounds () :Boolean
    {
        return _spawner.destructable;
    }

    public function doesHit (x :Number = NaN, y :Number = NaN, source :Object = null) :Collision
    {
        return _spawner.destructable && _spawner.health > 0 ?
            _spawner.hitCollision : _spawner.missCollision;
    }

    public function doHit (damage :Number, owner :int, inter :int, sowner :int) :void
    {
        if (_spawner.amOwner()) {
            _spawner.health -= damage;
        } else {
            PlatformerContext.net.sendMessage(
                    ShotMessage.shotHit(_spawner.id, damage, inter, sowner));
        }
        _spawner.wasHit = true;
    }

    public function doesCollide () :Boolean
    {
        return _spawner.destructable && _spawner.health > 0;
    }

    public function getCenterX () :Number
    {
        return _spawner.x + _spawner.width/2;
    }

    public function getCenterY () :Number
    {
        return _spawner.y + _spawner.height/2;
    }

    public function getLastDamager () :int
    {
        return _spawner.killer;
    }

    override public function tick (delta :Number) :void
    {
        super.tick(delta);
        if (!_spawner.shouldSpawn() || _spawner.disabled) {
            if (_spawner.spawning != 0) {
                _spawner.spawning = 0;
                _spawnId = 0;
            }
            return;
        }
        if (!_spawner.amOwner()) {
            if (_spawnId != 0) {
                if (_spawnDelay > 0) {
                    _spawnDelay -= delta;
                }
                if (_spawnDelay <= 0 && _spawner.spawning != _spawnId) {
                    spawn();
                }
            }
            if (_spawner.spawning > 0 && _spawnId != _spawner.spawning) {
                var newSpawnId :int = _spawner.spawning;
                if (_spawnId != 0) {
                    spawn();
                }
                _spawnDelay = _spawner.spawnDelay;
                _spawnId = newSpawnId;
            }
        } else {
            if (_spawnDelay > 0) {
                _spawnDelay -= delta;
            } else if (_spawner.spawning > 0) {
                PlatformerContext.net.notLocalSend(
                        SpawnerMessage.create, SpawnerMessage.SPAWN, _spawner.id, _spawnId);
                spawn();
                _spawnInterval = _spawner.spawnInterval;
            } else if (_spawnInterval > 0) {
                _spawnInterval -= delta;
            } else if ((_spawner.totalSpawns == 0 || _spawner.spawnCount < _spawner.totalSpawns) &&
                    (_spawner.maxConcurrent == 0 ||
                     _spawner.maxConcurrent > _spawner.spawns.length)) {
                _spawner.spawning = _controller.getBoard().reserveId();
                _spawnId = _spawner.spawning;
                _spawnDelay = _spawner.spawnDelay;
            }
        }
    }

    override public function postTick () :void
    {
        var ii :int;
        while (ii < _spawner.spawns.length) {
            var a :Actor = _controller.getBoard().getActor(_spawner.spawns[ii]);
            if (a == null || !a.shouldSpawn()) {
                _spawner.spawns.splice(ii, 1);
                _spawnInterval = Math.max(_spawnInterval, _spawner.deathInterval);
            } else {
                ii++;
            }
        }
        _spawner.wasHit = false;
        super.postTick();
    }

    protected function spawn () :void
    {
        var a :Actor = _spawner.genActor(_spawnId);
        _controller.getBoard().addActor(a);
        _spawner.spawns.push(a.id);
        _spawner.spawning = 0;
        _spawner.spawnCount++;
        _spawnId = 0;
    }

    protected var _spawner :Spawner;
    protected var _spawnInterval :Number;
    protected var _spawnDelay :Number;
    protected var _spawnId :int;
}
}
