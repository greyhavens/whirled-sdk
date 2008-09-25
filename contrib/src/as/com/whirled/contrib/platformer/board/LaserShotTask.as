// Whirled contrib library - too_ls for developing whirled games
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
// GNU Lesser General Public License for more detai_ls.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library.  If not, see <http://www.gnu.org/licenses/>.
//
// Copyright 2008 Three Rings Design
//
// $Id$

package com.whirled.contrib.platformer.board {

import com.whirled.contrib.platformer.piece.Actor;
import com.whirled.contrib.platformer.piece.BoundData;
import com.whirled.contrib.platformer.piece.LaserShot;

import com.whirled.contrib.platformer.game.CollisionHandler;
import com.whirled.contrib.platformer.game.LaserShotController;

public class LaserShotTask extends ShotTask
{
    public function LaserShotTask (lsc :LaserShotController, col :Collider)
    {
        _ls = lsc.getShot() as LaserShot;
        super(lsc, col);
    }

    override public function run () :void
    {
        collide(new LineData(_ls.x, _ls.y,
                _ls.x + _ls.dx * _ls.length, _ls.y + _ls.dy * _ls.length, BoundData.S_ALL));
        _s.hit = true;
    }

    override protected function didHit (hit :Number, ab :ActorBounds) :Number
    {
        var ch :CollisionHandler = _cc.getCollisionHandler(ab.controller);
        _s.hit = false;
        ch.collide(_s, ab, _cd);
        if (_ls.hits == null) {
            _ls.hits = new Array();
        }
        if (_s.hit) {
            _ls.hits.push(hit);
        }
        //_ls.hits.push([hit, _s.hit]);
        return int.MAX_VALUE;
    }

    override protected function preCalcMovement () :void
    {
        var line :LineData = new LineData(_ls.x, _ls.y,
                _ls.x + _ls.dx * _ls.length, _ls.y + _ls.dy * _ls.length, BoundData.S_ALL);
        var closehit :Number = _collider.findLineCloseHit(line);
        if (closehit < 1 && closehit >= 0) {
            _ls.length *= closehit;
        }
    }

    protected var _ls :LaserShot;
}
}
