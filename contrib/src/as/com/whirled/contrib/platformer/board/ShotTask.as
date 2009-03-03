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

package com.whirled.contrib.platformer.board {

import com.whirled.contrib.platformer.piece.Actor;
import com.whirled.contrib.platformer.piece.BoundData;
import com.whirled.contrib.platformer.piece.Dynamic;
import com.whirled.contrib.platformer.piece.Shot;

import com.whirled.contrib.platformer.game.CollisionHandler;
import com.whirled.contrib.platformer.game.SimpleCollision;
import com.whirled.contrib.platformer.game.ShotController;

public class ShotTask extends ColliderTask
{
    public function ShotTask (sc :ShotController, col :Collider)
    {
        super(sc, col);
        _s = sc.getShot();
        preCalcMovement();
    }

    override public function genCD (ct :ColliderTask = null) :ColliderDetails
    {
        _cd = new ColliderDetails(null, null, _delta);
        return _cd;
    }

    override public function run () :void
    {
        if (_s.ttl <= 0) {
            _delta += _s.ttl;
            if (_delta <= 0) {
                return;
            }
        }
        _line.update(_s.x, _s.y, _s.x + _s.dx * _delta, _s.y + _s.dy * _delta, true);
        _delta *= collide(_line);
        if (_cdb != null) {
            // shit happens
            var ch :CollisionHandler = _cc.getCollisionHandler(_cdb.controller);
            ch.collide(_s, _cdb, _cd);
            _cdb = null;
        }
        _s.x += _s.dx * _delta;
        _s.y += _s.dy * _delta;
        _delta = 0;
    }

    override public function isInteractive () :Boolean
    {
        return false;
    }

    protected function collide (line :LineData) :Number
    {
        var dynamics :Array = _collider.getDynamicBoundsByType(_s.inter);
        dynamics = dynamics.concat(_collider.getDynamicBoundsByType(Dynamic.GLOBAL));

        var closehit :Number = Number.MAX_VALUE;
        if (dynamics != null && dynamics.length > 0) {
            for each (var db :DynamicBounds in dynamics) {
                if (!db.dyn.isAlive() || !db.getRect().overlapsLine(line)) {
                    continue;
                }
                if (db is SimpleBounds) {
                    var sb :SimpleBounds = (db as SimpleBounds);
                    var arr :Array = line.polyIntersect(sb.getBoundLines());
                    if (arr[0] < closehit && _cc.getCollisionHandler(db.controller) != null) {
                        _cd.alines[0] = arr[1];
                        closehit = didHit(arr[0], db);
                    }
                } else if (db is CircleBounds) {
                    var cb :CircleBounds = (db as CircleBounds);
                    var dist :Number = line.getSegmentDist2(cb.x, cb.y);
                    if (dist < cb.r2) {
                        var hit :Number = line.getCircleIntersect(cb.x, cb.y, cb.radius);
                        if (hit < closehit && _cc.getCollisionHandler(cb.controller) != null) {
                            _cd.alines[0] = dist;
                            closehit = didHit(hit, cb);
                        }
                    }
                }
            }
        }
        return Math.min(closehit, 1);
    }

    protected function didHit (hit :Number, db :DynamicBounds) :Number
    {
        _cdb = db;
        return hit;
    }

    protected function preCalcMovement () :void
    {
        _line = new LineData(
                _s.x, _s.y, _s.x + _s.dx * _s.ttl, _s.y + _s.dy * _s.ttl, BoundData.S_ALL);
        var closehit :Number = _collider.findLineCloseHit(_line);
        if (closehit < 1 && closehit > 0) {
            _s.ttl *= closehit;
            _s.miss = new SimpleCollision(false, _s.genericMissSoundEffect);
        }
    }

    protected var _s :Shot;
    protected var _cdb :DynamicBounds;
    protected var _line :LineData;
}
}
