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

import com.whirled.contrib.platformer.PlatformerContext;

import com.whirled.contrib.platformer.piece.BoundData;
import com.whirled.contrib.platformer.piece.BoundedPiece;
import com.whirled.contrib.platformer.piece.Dynamic;
import com.whirled.contrib.platformer.piece.Rect;

import com.whirled.contrib.platformer.util.Maths;
import com.whirled.contrib.platformer.util.SectionalIndex;

import com.whirled.contrib.platformer.game.ActorController;
import com.whirled.contrib.platformer.game.DynamicController;
import com.whirled.contrib.platformer.game.RectDynamicController;
import com.whirled.contrib.platformer.game.ShotController;

public class Collider
{
    public static const MAX_DX :Number = 6;
    public static const MAX_DY :Number = 15;

    public static const DEBUG :Boolean = false;

    public function Collider (sx :int, sy :int)
    {
        _sindex = new SectionalIndex(sx, sy);
    }

    public function get tickCounter () :int
    {
        return _tickCounter;
    }

    public function getStartDelta (offset :int = 0) :Number
    {
        return (_tickCounter - offset) / 1000;
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
            var index :int = _sindex.getSectionFromTile(Math.min(p1.x, p2.x), Math.min(p1.y, p2.y));
            var sx :int = _sindex.getSectionX(index) - 1;
            var sy :int = _sindex.getSectionY(index) - 1;
            index = _sindex.getSectionFromTile(Math.max(p1.x, p2.x), Math.max(p1.y, p2.y));
            var osx :int = _sindex.getSectionX(index) + 1;
            var osy :int = _sindex.getSectionY(index) + 1;
            var ld :LineData = LineData.createFromPoints(p1, p2, type);
            for (var yy :int = sy; yy <= osy; yy++) {
                if (!_sindex.validY(yy)) {
                    continue;
                }
                for (var xx :int = sx; xx <= osx; xx++) {
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

    public function setBound (idx :int, bound :int) :void
    {
        // Top and Bottom bounds only prevent camera movement, not player movement
        if (idx == Board.TOP_BOUND || idx == Board.BOTTOM_BOUND) {
            return;
        }
        if (_boundLines[idx] != null) {
            for each (var sec :int in _boundLineSections[idx]) {
                var ix :int = _lines[sec].indexOf(_boundLines[idx]);
                _lines[sec].splice(ix, 1);
            }
        }
        _boundLineSections[idx] = new Array();
        if (bound <= 0) {
            _boundLines[idx] = null;
        } else {
            var p1 :Point;
            var p2 :Point;
            if (idx == Board.TOP_BOUND || idx == Board.BOTTOM_BOUND) {
                p1 = new Point(0, bound);
                p2 = new Point(_sindex.getSectionWidth() * 1000, bound);
            } else {
                p1 = new Point(bound, 0);
                p2 = new Point(bound, _sindex.getSectionHeight() * 1000);
            }
            _boundLines[idx] = LineData.createFromPoints(p1, p2, BoundData.ALL | BoundData.S_ALL);
        }
    }

    public function getLines (d :Dynamic) :Array
    {
        if (PlatformerContext.gctrl.game.amServerAgent() && !d.amOwner()) {
            return new Array();
        }
        return getLinesPt(d.x, d.y);
    }

    public function getLinesPt (x :Number, y :Number) :Array
    {
        var index :int = _sindex.getSectionFromTile(Math.floor(x), Math.floor(y));
        //trace("getLines for index: " + index);
        updateBoundLines(index);
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
                updateBoundLines(index);
                if (_lines[index] != null) {
                    lines = lines.concat(_lines[index]);
                }
            }
        }
        return lines;
    }

    public function updateBoundLines (idx :int) :void
    {
        for (var ii :int = Board.TOP_BOUND; ii <= Board.LEFT_BOUND; ii++) {
            if (_boundLines[ii] == null) {
                continue;
            }
            if (_boundLineSections[ii].indexOf(idx) != -1) {
                continue;
            }
            var x :int = _sindex.getSectionX(idx);
            var y :int = _sindex.getSectionY(idx);
            var sw :int = _sindex.getSectionWidth();
            var sh :int = _sindex.getSectionHeight();
            var line :LineData = _boundLines[ii];
            if ((line.x1 > (x - 1) * sw && line.x1 < (x + 2) * sw) ||
                (line.y1 > (y - 1) * sh && line.y1 < (y + 2) * sh)) {
                if (_lines[idx] == null) {
                    _lines[idx] = new Array();
                }
                _lines[idx].push(line);
                _boundLineSections[ii].push(idx);
            }
        }
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
        return _dynamics[d.id];
    }

    public function addDynamic (dc :DynamicController) :void
    {
        var d :Dynamic = dc.getDynamic();
        var db :DynamicBounds = getBounds(dc);
        if (db != null) {
            _dynamics[d.id] = db;
            var arr :Array = getDynamicBoundsByType(d.inter);
            trace("adding bounds for (" + d.id + ") of type: " + d.inter);
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

    public function updateInter (dc :DynamicController, inter :int) :void
    {
        var d :Dynamic = dc.getDynamic();
        if (d.inter != inter && d.amOwner()) {
            updateInterTo(d, d.inter, inter);
        }
    }

    public function updateInterTo (d :Dynamic, oldInter :int, newInter :int) :void
    {
        var db :DynamicBounds = getDynamicBounds(d);
        var arr :Array = getDynamicBoundsByType(oldInter);
        var idx :int = arr.indexOf(db);
        if (idx != -1) {
            arr.splice(idx, 1);
        }
        d.inter = newInter;
        arr = getDynamicBoundsByType(newInter);
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
            delete _dynamics[d.id];
            var arr :Array = getDynamicBoundsByType(d.inter);
            var idx :int = arr.indexOf(db);
            if (idx != -1) {
                arr.splice(idx, 1);
            }
            trace("dynamic(" + d.id + ") removed inter: " + d.inter + " remaining bounds: " + arr.length);
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

    public function tick (delta :int) :Boolean
    {
        var runTasks :Array = new Array();
        _tickCounter += delta;
        var time :int = getTimer();
        var quickTasks :int = 0;
        for each (var task :ColliderTask in _tasks) {
            task.init(delta / 1000);
            if (!task.isInteractive()) {
                task.genCD();
                task.run();
                quickTasks++;
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
                    debug("cd is null from task: " + ClassUtil.getClassName(task));
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
        if (runTime + initTime > 9) {
            debug("collider quick: " + quickTasks + ", slow: " + runTasks.length +
                    ", runs: " + runs + ", runTime: " + runTime + ", initTime: " + initTime);
            return true;
        }
        return false;
        /*
        trace("collider init: " + initTime + " run " + runTasks.length + " in " + runTime +
            " finish: " + finishTime + "  run called: " + runs);
        */
    }

    public function translateDynamic (d :Dynamic, dX :Number, dY :Number) :void
    {
        var db :DynamicBounds = _dynamics[d.id];
        db.translate(dX, dY);
    }

    public function doesInteract (sinter :int, tinter :int) :Boolean
    {
        if ((sinter == Dynamic.DEAD && tinter != Dynamic.GLOBAL) ||
                (tinter == Dynamic.DEAD && sinter != Dynamic.GLOBAL)) {
            return false;
        }
        return sinter != tinter;
    }

    public function isInteresting (source :DynamicBounds, target :DynamicBounds) :Boolean
    {
        if ((source is ActorBounds || source is SimpleBounds) &&
            (target is ActorBounds || target is SimpleBounds)) {
            return closeIndices(source.getRect(), target.getRect());
        }
        return false;
    }

    public function findLineCloseHit (line :LineData) :Number
    {
        var lines :Array = getLinesFromLine(line);
        var closehit :Number = Number.MAX_VALUE;
        for each (var ld :LineData in lines) {
            if (ld.isIntersecting(line) &&
                    (BoundData.blockInner(ld.type, true) && ld.isInside(line.x1, line.y1) ||
                     BoundData.blockOuter(ld.type, true) && ld.isOutside(line.x1, line.y1))) {
                var hit :Number = line.findIntersect(ld);
                if (hit < closehit) {
                    closehit = hit;
                }
            }
        }
        return closehit;
    }

    public function collide (source :Object, target :Object) :Array
    {
        var cols :Array = new Array();
        if (source is SimpleBounds && target is SimpleBounds) {
            for each (var line :LineData in (target as SimpleBounds).getBoundLines()) {
                if (line.polyIntersecting((source as SimpleBounds).getMovementBoundLines())) {
                    cols.push(line);
                }
            }
            if (cols.length == 0 &&
                    (source as SimpleBounds).getMovementBoundLines()[0].polyIntersecting(
                        (target as SimpleBounds).getBoundLines())) {
                cols.push(null);
            }
        } else if (source is CircleBounds && target is CircleBounds) {
            var cs :CircleBounds = source as CircleBounds;
            var ct :CircleBounds = target as CircleBounds;
            var dist :Number = Maths.getDist2(cs.x, cs.y, ct.x, ct.y);
            if (dist < cs.r2 + ct.r2) {
                cols.push(dist);
            }
        } else if (source is CircleBounds && target is SimpleBounds) {
            cs = source as CircleBounds;
            for each (line in (target as SimpleBounds).getBoundLines()) {
                dist = line.getSegmentDist2(cs.x, cs.y);
                if (dist < cs.r2) {
                    cols.push(line);
                }
            }
        } else if (source is SimpleBounds && target is CircleBounds) {
            ct = target as CircleBounds;
            for each (line in (source as SimpleBounds).getMovementBoundLines()) {
                dist = line.getSegmentDist2(ct.x, ct.y);
                if (dist < ct.r2) {
                    cols.push(dist);
                    break;
                }
            }
        }
        return cols;
    }

    protected function getBounds (dc :DynamicController) :DynamicBounds
    {
        if (dc is ActorController) {
            return new SimpleActorBounds(dc as ActorController, this);
        } else if (dc is RectDynamicController) {
            return new RectDynamicBounds(dc as RectDynamicController, this);
        }
        return null;
    }

    protected function closeIndices (rect1 :Rect, rect2 :Rect) :Boolean
    {
        return rect1.overlaps(rect2, 1);
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

    protected function debug (str :String) :void
    {
        if (DEBUG) {
            trace(str);
        }
    }

    protected var _lines :Array = new Array();
    protected var _dynamics :Object = new Object();
    protected var _dynamicBounds :Array = new Array();
    protected var _tasks :Array = new Array();
    protected var _boundLines :Array = new Array();
    protected var _boundLineSections :Array = new Array();
    protected var _sindex :SectionalIndex;
    protected var _tickCounter :int;

    protected const MIN_DELTA :Number = 1/100;

}
}
