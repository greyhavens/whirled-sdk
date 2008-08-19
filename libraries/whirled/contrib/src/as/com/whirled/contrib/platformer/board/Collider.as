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

import flash.geom.Point;

import com.threerings.util.HashMap;
import com.threerings.util.ClassUtil;

import com.whirled.contrib.platformer.piece.Actor;
import com.whirled.contrib.platformer.piece.BoundData;
import com.whirled.contrib.platformer.piece.BoundedPiece;
import com.whirled.contrib.platformer.piece.Dynamic;

import com.whirled.contrib.platformer.util.Maths;
import com.whirled.contrib.platformer.util.SectionalIndex;

import com.whirled.contrib.platformer.game.ActorController;
import com.whirled.contrib.platformer.game.DynamicController;
import com.whirled.contrib.platformer.game.ShotController;

public class Collider
{
    public static const MAX_DX :Number = 6;
    public static const MAX_DY :Number = 15;

    public function Collider (sx :int, sy :int)
    {
        _sindex = new SectionalIndex(sx, sy);
    }

    public function addBoundedPiece (p :BoundedPiece) :void
    {
        var offset :Point = new Point(p.x, p.y);
        for (var ii :int = 0; ii < p.numBounds(); ii++) {
            if (p.getBound(ii) > 0) {
                var line :Array = p.getBoundLine(ii);
                addLine(line[0].add(offset), line[1].add(offset), p.getBound(ii));
            }
        }
    }

    public function addLine (p1 :Point, p2 :Point, type :int) :void
    {
        if (type > 0) {
            var index :int = _sindex.getSectionFromTile(p1.x, p1.y);
            var sx :int = _sindex.getSectionX(index);
            var sy :int = _sindex.getSectionY(index);
            index = _sindex.getSectionFromTile(p2.x, p2.y);
            var osx :int = _sindex.getSectionX(index);
            var osy :int = _sindex.getSectionY(index);
            var ld :LineData = LineData.createFromPoints(p1, p2, type);
            for (var yy :int = Math.min(sy, osy) - 1; yy <= Math.max(sy, osy) + 1; yy++) {
                if (!_sindex.validY(yy)) {
                    continue;
                }
                for (var xx :int = Math.min(sx, osx) - 1; xx <= Math.max(sx, osx) + 1; xx++) {
                    if (!_sindex.validX(xx)) {
                        continue;
                    }
                    index = _sindex.getSectionIndex(xx, yy);
                    if (_lines[index] == null) {
                        _lines[index] = new Array();
                    }
                    _lines[index].push(ld);
                    //trace("index " + index + " " + ld);
                }
            }
        }
    }

    public function getLines (d :Dynamic) :Array
    {
        var index :int = _sindex.getSectionFromTile(Math.floor(d.x), Math.floor(d.y));
        var lines :Array = _lines[index];
        return (lines == null ? new Array() : lines);
    }

    public function getLinesFromLine (line :LineData) :Array
    {
        var lines :Array = new Array();
        var x1 :int = _sindex.getSectionXFromTile(
                Math.min(Math.floor(line.x1), Math.floor(line.x2)));
        var x2 :int = _sindex.getSectionXFromTile(
                Math.max(Math.ceil(line.x1), Math.ceil(line.x2)));
        var y1 :int = _sindex.getSectionYFromTile(
                Math.min(Math.floor(line.y1), Math.floor(line.y2)));
        var y2 :int = _sindex.getSectionYFromTile(
                Math.max(Math.ceil(line.y1), Math.ceil(line.y2)));
        for (var yy :int = y1; yy <= y2; yy++) {
            for (var xx :int = x1; xx <= x2; xx++) {
                var index :int = _sindex.getSectionIndex(xx, yy);
                if (_lines[index] != null) {
                    lines = lines.concat(_lines[index]);
                }
            }
        }
        return lines;
    }

    public function getActorBoundsByType (type :int) :Array
    {
        if (_actorBounds[type] == null) {
            _actorBounds[type] = new Array();
        }
        return _actorBounds[type];
    }

    public function getActorBounds (a :Actor) :SimpleActorBounds
    {
        return _actors.get(a);
    }

    public function addActor (ac :ActorController) :void
    {
        var a :Actor = ac.getActor();
        var sab :SimpleActorBounds = new SimpleActorBounds(ac, this);
        _actors.put(a, sab);
        var arr :Array = getActorBoundsByType(a.inter);
        arr.push(sab);
        var task :ColliderTask = ac.createTask();
        if (task != null) {
            _tasks.push(task);
        }
    }

    public function updateInter (ac :ActorController, inter :int) :void
    {
        var a :Actor = ac.getActor();
        if (a.inter == inter) {
            return;
        }
        var sab :SimpleActorBounds = getActorBounds(a);
        var arr :Array = getActorBoundsByType(a.inter);
        var idx :int = arr.indexOf(sab);
        if (idx != -1) {
            arr.splice(idx, 1);
        }
        a.inter = inter;
        arr = getActorBoundsByType(a.inter);
        arr.push(sab);
    }

    public function addShot (sc :ShotController) :void
    {
        var task :ColliderTask = sc.createTask();
        if (task != null) {
            _tasks.push(task);
        }
    }

    public function removeDynamic (dc :DynamicController) :void
    {
        if (dc is ActorController) {
            var a :Actor = (dc as ActorController).getActor();
            var sab :SimpleActorBounds = getActorBounds(a);
            _actors.remove(a);
            var arr :Array = getActorBoundsByType(a.inter);
            var idx :int = arr.indexOf(sab);
            if (idx != -1) {
                arr.splice(idx, 1);
            }
        }
        for (var ii :int = 0; ii < _tasks.length; ii++) {
            if (_tasks[ii].getController() == dc) {
                _tasks.splice(ii, 1);
                break;
            }
        }
    }

    public function tick (delta :Number) :void
    {
        var runTasks :Array = new Array();
        for each (var task :ColliderTask in _tasks) {
            task.init(delta);
            if (!task.isInteractive()) {
                task.genCD();
                task.run();
            } else {
                runTasks.push(task);
            }
        }
        //trace("collider has " + runTasks.length + " runTasks");
        while (true) {
            var firstTask :ColliderTask = null;
            for each (task in runTasks) {
                if (task.isComplete()) {
                    continue;
                }
                var cd :ColliderDetails = task.genCD();
                if (cd == null) {
                    trace("cd is null from task: " + ClassUtil.getClassName(task));
                }
                if (firstTask == null || firstTask.getCD() == null ||
                        firstTask.getCD().rdelta < cd.rdelta) {
                    firstTask = task;
                }
            }
            if (firstTask == null) {
                break;
            }
            if (firstTask.getCD() != null) {
                firstTask.run();
            }
        }
        for each (task in _tasks) {
            task.finish();
        }
    }

    public function walkActor (ac :ActorController, dX :Number, delta :Number) :void
    {
        var a :Actor = ac.getActor();
        var sab :SimpleActorBounds = _actors.get(a);
        if (a.attached == null) {
            a.dy -= 15 * delta;
            a.dy = Math.max(a.dy, -MAX_DY);
            a.dx += dX * delta;
            a.dx -= Maths.sign0(a.dx) * Maths.limit(9 * delta, Math.abs(a.dx));
            a.dx = Maths.limit(a.dx, MAX_DX);
        }
        var attached :LineData;
        var oldDelta :Number = delta;
        var oldDist :Number = 1;
        while (delta > 0) {
            if (a.attached != null && a.attached != attached) {
                attached = a.attached;
                //var detach :Boolean = false;
                // Newly attached to a walkable tile, preserve our momentum
                if (Math.abs(a.attached.iy) < a.maxWalkable) {
                    var dot :Number = a.dx * a.attached.ix + a.dy * a.attached.iy;
                    if (a.attached.ix >= 0) {
                        dot += dX * delta;
                    } else {
                        dot -= dX * delta;
                    }
                    dot -= Maths.sign0(dot) * Maths.limit(9 * delta, Math.abs(dot));
                    dot = Maths.limit(dot, MAX_DX);
                    a.dx = dot * a.attached.ix;
                    a.dy = dot * a.attached.iy;
                // Newly attached to an unwalkable tile, start to slide
                } else {
                    if (a.attached.iy > 0) {
                        a.dx = - a.attached.ix;
                        a.dy = - a.attached.iy;
                    } else {
                        a.dx = a.attached.ix;
                        a.dy = a.attached.iy;
                    }
                    a.dx *= 6;
                    a.dy *= 6;
                    a.dx = Maths.limit(a.dx, MAX_DX);
                    a.dy = Maths.limit(a.dy, MAX_DY);
                }
            }
            //delta = sab.move(delta);
            if (oldDist == 0 && oldDelta - delta == 0) {
                break;
            }
            oldDist = oldDelta - delta;
            oldDelta = delta;
        }
    }

    public function flyActor (a :Actor, delta :Number) :void
    {
        var sab :SimpleActorBounds = _actors.get(a);
        sab.translate(a.dx * delta, a.dy * delta);
    }

    public function translateActor (a :Actor, dX :Number, dY :Number) :void
    {
        var sab :SimpleActorBounds = _actors.get(a);
        sab.translate(dX, dY);
    }

    public function jumpActor (ac :ActorController, dX :Number, delta :Number) :void
    {
        var a :Actor = ac.getActor();
        if (a.attached != null && Math.abs(a.attached.iy) < a.maxWalkable) {
            a.attached = null;
            a.dy = 8;
        } else if (a.attached == null) {
            a.dy += 10 * delta;
        }
        walkActor(ac, dX, delta);
    }

    protected var _lines :Array = new Array();
    protected var _actors :HashMap = new HashMap();
    protected var _actorBounds :Array = new Array();
    protected var _tasks :Array = new Array();
    protected var _sindex :SectionalIndex;

    protected const MIN_DELTA :Number = 1/100;

}
}
