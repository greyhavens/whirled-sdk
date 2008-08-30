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
import flash.utils.getTimer;

import com.threerings.util.HashMap;
import com.threerings.util.ClassUtil;

import com.whirled.contrib.platformer.piece.Actor;
import com.whirled.contrib.platformer.piece.BoundedPiece;
import com.whirled.contrib.platformer.piece.Dynamic;
import com.whirled.contrib.platformer.piece.Rect;

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

    public function getStartDelta () :Number
    {
        return _tickCounter / 1000;
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

    public function getDynamicBoundsByType (type :int) :Array
    {
        if (_dynamicBounds[type] == null) {
            _dynamicBounds[type] = new Array();
        }
        return _dynamicBounds[type];
    }

    public function getDynamicBounds (d :Dynamic) :DynamicBounds
    {
        return _dynamics.get(d);
    }

    public function addDynamic (dc :DynamicController) :void
    {
        var d :Dynamic = dc.getDynamic();
        var db :DynamicBounds = getBounds(dc);
        if (db != null) {
            _dynamics.put(d, db);
            var arr :Array = getDynamicBoundsByType(d.inter);
            arr.push(db);
        }
        var task :ColliderTask = dc.getTask();
        if (task != null) {
            if (d.inter == Dynamic.GLOBAL) {
                _tasks.unshift(task);
            } else {
                _tasks.push(task);
            }
        }
    }

    public function updateInter (ac :ActorController, inter :int) :void
    {
        var a :Actor = ac.getActor();
        if (a.inter == inter) {
            return;
        }
        var db :DynamicBounds = getDynamicBounds(a);
        var arr :Array = getDynamicBoundsByType(a.inter);
        var idx :int = arr.indexOf(db);
        if (idx != -1) {
            arr.splice(idx, 1);
        }
        a.inter = inter;
        arr = getDynamicBoundsByType(a.inter);
        arr.push(db);
    }

    public function addShot (sc :ShotController) :void
    {
        var task :ColliderTask = sc.getTask();
        if (task != null) {
            _tasks.push(task);
        }
    }

    public function removeDynamic (dc :DynamicController) :void
    {
        var d :Dynamic = dc.getDynamic();
        var db :DynamicBounds = getDynamicBounds(d);
        if (db != null) {
            _dynamics.remove(d);
            var arr :Array = getDynamicBoundsByType(d.inter);
            var idx :int = arr.indexOf(db);
            if (idx != -1) {
                arr.splice(idx, 1);
            }
            trace("dynamic removed inter: " + d.inter + " remaining bounds: " + arr.length);
        }
        for (var ii :int = 0; ii < _tasks.length; ii++) {
            if (_tasks[ii].getController() == dc) {
                _tasks.splice(ii, 1);
                break;
            }
        }
    }

    public function numTasks () :int
    {
        return _tasks.length;
    }

    public function numBounds () :int
    {
        var bounds :int = getDynamicBoundsByType(Dynamic.GLOBAL).length;
        bounds += getDynamicBoundsByType(Dynamic.PLAYER).length;
        bounds += getDynamicBoundsByType(Dynamic.ENEMY).length;
        return bounds;
    }

    public function tick (delta :int) :void
    {
        var runTasks :Array = new Array();
        _tickCounter += delta;
        var time :int = getTimer();
        for each (var task :ColliderTask in _tasks) {
            task.init(delta / 1000);
            if (!task.isInteractive()) {
                task.genCD();
                task.run();
            } else {
                runTasks.push(task);
            }
        }
        var initTime :int = getTimer() - time;
        var lastTask :ColliderTask;
        var runs :int = 0;
        while (true) {
            var firstTask :ColliderTask = null;
            for each (task in runTasks) {
                if (task.isComplete()) {
                    continue;
                }
                var cd :ColliderDetails = task.genCD(lastTask);
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
            lastTask = firstTask;
            if (firstTask.getCD() != null) {
                firstTask.run();
                runs++;
            }
        }
        var runTime :int = getTimer() - time - initTime;
        for each (task in _tasks) {
            task.finish();
        }
        var finishTime :int = getTimer() - time - initTime - runTime;
        /*
        trace("collider init: " + initTime + " run " + runTasks.length + " in " + runTime +
            " finish: " + finishTime + "  run called: " + runs);
        */
    }

    public function translateDynamic (d :Dynamic, dX :Number, dY :Number) :void
    {
        var db :DynamicBounds = _dynamics.get(d);
        db.translate(dX, dY);
    }

    public function doesInteract (sinter :int, tinter :int) :Boolean
    {
        if (sinter == Dynamic.DEAD || tinter == Dynamic.DEAD) {
            return false;
        }
        return sinter != tinter;
    }

    public function isInteresting (source :DynamicBounds, target :DynamicBounds) :Boolean
    {
        if (source is SimpleActorBounds && target is SimpleActorBounds) {
            return closeIndices(source.getRect(), target.getRect());
        }
        return false;
    }

    public function collide (source :DynamicBounds, target :DynamicBounds) :Array
    {
        var cols :Array = new Array();
        if (source is SimpleActorBounds && target is SimpleActorBounds) {
            for each (var line :LineData in (target as SimpleActorBounds).lines) {
                if (line.polyIntersecting((source as SimpleActorBounds).mlines)) {
                    cols.push(line);
                }
            }
        }
        return cols;
    }

    protected function getBounds (dc :DynamicController) :DynamicBounds
    {
        if (dc is ActorController) {
            return new SimpleActorBounds(dc as ActorController, this);
        }
        return null;
    }

    protected function closeIndices (rect1 :Rect, rect2 :Rect) :Boolean
    {
        rect1.grow(1);
        rect2.grow(1);
        return rect1.overlaps(rect2);
        /*
        return !(_sindex.getSectionXFromTile(rect1.x) >
                _sindex.getSectionXFromTile(rect2.x + rect2.width) ||
            _sindex.getSectionXFromTile(rect1.x + rect1.width) <
                _sindex.getSectionXFromTile(rect2.x) ||
            _sindex.getSectionYFromTile(rect1.y) >
                _sindex.getSectionYFromTile(rect2.y + rect2.height) ||
            _sindex.getSectionYFromTile(rect1.y + rect1.height) <
                _sindex.getSectionYFromTile(rect2.y));
        */
    }

    protected var _lines :Array = new Array();
    protected var _dynamics :HashMap = new HashMap();
    protected var _dynamicBounds :Array = new Array();
    protected var _tasks :Array = new Array();
    protected var _sindex :SectionalIndex;
    protected var _tickCounter :int;

    protected const MIN_DELTA :Number = 1/100;

}
}
