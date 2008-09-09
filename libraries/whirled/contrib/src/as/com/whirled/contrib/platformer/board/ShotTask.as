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
import com.whirled.contrib.platformer.piece.Shot;

import com.whirled.contrib.platformer.game.CollisionHandler;
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
        var dynamics :Array = _collider.getDynamicBoundsByType(_s.inter);
        var closehit :Number = int.MAX_VALUE;
        var cab :ActorBounds = null;
        var line :LineData = new LineData(
                _s.x, _s.y, _s.x + _s.dx * _delta, _s.y + _s.dy * _delta, BoundData.S_ALL);
        if (dynamics != null && dynamics.length > 0) {
            for each (var db :DynamicBounds in dynamics) {
                if (db is SimpleActorBounds) {
                    var sab :SimpleActorBounds = (db as SimpleActorBounds);
                    var arr :Array = line.polyIntersect(sab.lines);
                    if (arr[0] < closehit) {
                        closehit = arr[0];
                        cab = sab;
                        _cd.alines[0] = arr[1];
                    }
                } else if (db is CircleBounds) {
                    var cb :CircleBounds = (db as CircleBounds);
                    var dist :Number = line.getSegmentDist2(cb.x, cb.y);
                    if (dist < cb.r2) {
                        var hit :Number = line.getCircleIntersect(cb.x, cb.y, cb.radius);
                        if (hit < closehit) {
                            closehit = hit;
                            cab = cb;
                            _cd.alines[0] = dist;
                        }
                    }
                }
            }
            if (cab != null) {
                // shit happens
                _delta *= closehit;
                var ch :CollisionHandler = _cc.getCollisionHandler(cab.controller);
                ch.collide(_s, cab, _cd);
            }
        }
        _s.x += _s.dx * _delta;
        _s.y += _s.dy * _delta;
        _delta = 0;
    }

    override public function isInteractive () :Boolean
    {
        return false;
    }

    protected function preCalcMovement () :void
    {
        var line :LineData = new LineData(
                _s.x, _s.y, _s.x + _s.dx * _s.ttl, _s.y + _s.dy * _s.ttl, BoundData.S_ALL);
        var closehit :Number = findLineCloseHit(line);
        if (closehit < 1 && closehit > 0) {
            _s.ttl *= closehit;
        }
    }

    protected function findLineCloseHit (line :LineData) :Number
    {
        var lines :Array = _collider.getLinesFromLine(line);
        //trace("projectile line: " + line + " testing against " + lines.length + " lines");
        var closehit :Number = int.MAX_VALUE;
        for each (var ld :LineData in lines) {
            if (ld.isIntersecting(line) &&
                    (BoundData.blockInner(ld.type, true) && ld.isInside(_s.x, _s.y) ||
                     BoundData.blockOuter(ld.type, true) && ld.isOutside(_s.x, _s.y))) {
                var hit :Number = line.findIntersect(ld);
                //trace("projectile found intersect " + ld + " hit: " + hit);
                if (hit < closehit) {
                    closehit = hit;
                }
            }
        }
        return closehit;
    }

    protected var _s :Shot;
}
}
