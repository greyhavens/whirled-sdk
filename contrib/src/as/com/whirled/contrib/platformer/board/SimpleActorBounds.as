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

import com.whirled.contrib.platformer.PlatformerContext;
import com.whirled.contrib.platformer.piece.Actor;
import com.whirled.contrib.platformer.piece.BoundData;
import com.whirled.contrib.platformer.piece.Dynamic;
import com.whirled.contrib.platformer.util.Maths;
import com.whirled.contrib.platformer.util.Metrics;

import com.whirled.contrib.platformer.game.ActorController;
import com.whirled.contrib.platformer.game.CollisionHandler;

/**
 * Provides collision detection support for an actor that has an axis aligned rectangular bounding
 * box.
 */
public class SimpleActorBounds extends ActorBounds
    implements SimpleBounds
{
    public static const DEBUG :Boolean = false;

    public static var fcCalls :int = 0;

    public function SimpleActorBounds (ac :ActorController, c :Collider)
    {
        super(ac, c);
        updateBounds();
    }

    public function set hitX (hitX :Boolean) :void
    {
        _hitX = hitX;
    }

    public function set hitY (hitY :Boolean) :void
    {
        _hitY = hitY;
    }

    public function get hitX () :Boolean
    {
        return _hitX;
    }

    public function get hitY () :Boolean
    {
        return _hitY;
    }

    public function getBoundLines () :Array
    {
        return _lines;
    }

    public function getMovementBoundLines () :Array
    {
        return (_resetMLines ? null : _mlines);
    }

    public function getBottomLine () :LineData
    {
        return _lines[3];
    }

    override public function updateBounds () :void
    {
        if (_lines == null) {
            _lines = new Array();
            _lines.push(dynLD(0, 0, 0, actor.height, ACTOR_BOUND));
            _lines.push(dynLD(0, actor.height, actor.width, actor.height, ACTOR_BOUND));
            _lines.push(dynLD(actor.width, actor.height, actor.width, 0, ACTOR_BOUND));
            _lines.push(dynLD(actor.width, 0, 0, 0, ACTOR_BOUND));
        } else {
            dynUpdateLD(_lines[0], 0, 0, 0, actor.height);
            dynUpdateLD(_lines[1], 0, actor.height, actor.width, actor.height);
            dynUpdateLD(_lines[2], actor.width, actor.height, actor.width, 0);
            dynUpdateLD(_lines[3], actor.width, 0, 0, 0);
        }
    }

    /**
     * Translates the actor and updates all the boundary data.
     */
    override public function translate (dX :Number, dY :Number) :void
    {
        super.translate(dX, dY);
        updateBounds();
    }

    /**
     * Returns true if these actors are colliding.
     */
    public function simpleCollide (ab :SimpleActorBounds) :Boolean
    {
        return simpleCollideLines (ab.getBoundLines());
    }

    public function simpleCollideLines (olines :Array) :Boolean
    {
        return LineData.doPolygonsCollide(_lines, olines);
    }

    /**
     * Returns true if any of the actor bounds crosses the line after the translation.
     */
    public function didCross (ld :LineData, xd :Number, yd :Number) :Boolean
    {
        return ld.didPolyCrossDelta(_lines, xd, yd);
    }

    /**
     * Returns an array of crossing lines.
     */
    public function crossers (ld :LineData, xd :Number, yd :Number) :Array
    {
        var ret :Array = new Array();
        for each (var line :LineData in _lines) {
            if (ld.didCrossDelta(line, xd, yd)) {
                ret.push(line);
            }
        }
        return ret;
    }

    /**
     * Returns true if any part of the actor is inside the convex shape made by the two lines.
     */
    public function isContained (ld0 :LineData, ld1 :LineData, sides :Array) :Boolean
    {
        for each (var line :LineData in _lines) {
            if (((sides[0] > 0 && ld0.isOutside(line.x1, line.y1)) ||
                 (sides[0] < 0 && ld0.isInside(line.x1, line.y1))) && (
                 (sides[1] > 0 && ld1.isOutside(line.x1, line.y1)) ||
                 (sides[1] < 0 && ld1.isInside(line.x1, line.y1)))) {
                return true;
            }
        }
        return false;
    }

    public function adjustHeight (newHeight :Number) :Boolean
    {
        var oldHeight :Number = actor.height;
        actor.height = newHeight;
        updateBounds();
        if (newHeight <= oldHeight) {
            _rect.height = newHeight;
            return true;
        }
        var delta :Number = oldHeight - newHeight;
        var clines :Array = _collider.getLines(actor);
        for each (var ld :LineData in clines) {
            if (actor.attached == ld || !BoundData.doesBound(ld.type, actor.projCollider) ||
                !ld.polyIntersecting(_lines)) {
                continue;
            }
            if ((BoundData.blockOuter(ld.type, actor.projCollider) &&
                    ld.isOutside(_lines[1].x1, _lines[1].y1 + delta) &&
                    ld.isOutside(_lines[1].x2, _lines[1].y2 + delta) &&
                    !ld.isLineOutside(_lines[1])) ||
                    (BoundData.blockInner(ld.type, actor.projCollider) &&
                    ld.isInside(_lines[1].x1, _lines[1].y1 + delta) &&
                    ld.isInside(_lines[1].x2, _lines[1].y2 + delta) &&
                    !ld.isLineInside(_lines[1]))) {
                actor.height = oldHeight;
                updateBounds();
                return false;
            }
        }
        actor.height = newHeight;
        _rect.height = newHeight;
        updateBounds();
        return true;
    }

    public function findColliders (delta :Number, cd :ColliderDetails = null) :ColliderDetails
    {
        _resetMLines = true;
        if (delta <= 0) {
            return new ColliderDetails(null, null, 0);
        }
        if (cd == null || cd.colliders == null) {
            cd = new ColliderDetails(_collider.getLines(actor), getInteractingBounds(), delta);
        } else if (cd.colliders.length == 0 && cd.acolliders.length == 0) {
            return cd;
        } else {
            cd.reset(delta);
        }
        log("found", cd.colliders.length, "lines and", cd.acolliders.length, "interesting bounds for", getBottomLine());
        var beforeX :Number = actor.x;
        var beforeY :Number = actor.y;
        var didCollide :Boolean = false;

        do {
            startLog();
            fcCalls++;
            var cdX :Number = actor.dx * delta;
            var cdY :Number = actor.dy * delta;
            if (PlatformerContext.gctrl.game.amServerAgent() && !actor.amOwner()) {
                cdX = 0;
                cdY = 0;
            }
            var verify :Array = new Array();
            genMovementBounds(cdX, cdY);
            log("testing delta", delta, "with (", cdX, ",", cdY, ") on", getBottomLine(), "->",_mlines[5]);

            // Find all the static lines we collide with
            if (cd.colliders.length > 0) {
                var colTest :Array = new Array(cd.colliders.length);
                //verify = cd.colliders;
                //cd.colliders = new Array();
                for (var ii :int = 0; ii < cd.colliders.length; ii++) {
                //for each (var ld :LineData in cd.colliders) {
                    var ld :LineData = cd.colliders[ii];
                    if (actor.attached == ld || !BoundData.doesBound(ld.type, actor.projCollider)) {
                        colTest[ii] = -1;
                        continue;
                    }
                    if (ld.polyIntersecting(_mlines)) {
                            //&& !ld.polyIntersecting(_lines)) {
                        colTest[ii] = 1;
                        //cd.colliders.push(ld);
                        //log("adding intersecting ", ld);
                    } else {
                        //log("ignoring non intersecting ", ld);
                        colTest[ii] = 0;
                    }
                }
                for (ii = 0; ii < cd.colliders.length; ii++) {
                    if (colTest[ii] != 1) {
                        continue;
                    }
                    for (var jj :int = 0; jj < cd.colliders.length; jj++) {
                        if (ii == jj || colTest[jj] != 0) {
                            continue;
                        }
                        if (cd.colliders[ii].isConnected(cd.colliders[jj]) != null) {
                            colTest[jj] = 2;
                        }
                    }
                }
                verify = cd.colliders;
                cd.colliders = new Array();
                var ignored :Array = new Array();
                for (ii = 0; ii < colTest.length; ii++) {
                    if (colTest[ii] >= 1) {
                        cd.colliders.push(verify[ii]);
                        ignored.push(colTest[ii]);
                        log("adding interesting", verify[ii], "ignored", ignored[ignored.length - 1]);
                    } else {
                        log("ignoring uninteresting", verify[ii]);
                    }
                }
            }

            // Filter out those lines which don't block our movement direction
            if (cd.colliders.length > 0) {
                verify = cd.colliders;
                cd.colliders = new Array();

                for (ii = 0; ii < verify.length; ii++) {
                    if (!BoundData.doesBound(verify[ii].type)) {
                        cd.colliders.push(verify[ii]);
                        log("ignoring non bounding collider:", verify[ii]);
                        continue;
                    }
                    var connected :Boolean = false;
                    for (jj = 0; jj < verify.length; jj++) {
                        if (ii == jj) {
                            continue;
                        }
                        var sides :Array = verify[ii].isConnected(verify[jj]);
                        if (sides != null) {
                            connected = true;
                            if (ignored[ii] != 2 && ignored[jj] != 2 &&
                                    BoundData.getNormalBound(verify[ii].type) != BoundData.ALL &&
                                    isContained(verify[ii], verify[jj], sides)) {
                                ignored[ii] = 3;
                                log("ignoring contained collider:", verify[ii]);
                                break;
                            }
                            if (((sides[1] > 0 && !verify[jj].anyOutside(_lines)) ||
                                 (sides[1] < 0 && !verify[jj].anyInside(_lines))) &&
                                !((sides[0] > 0 && !verify[ii].anyOutside(_lines)) ||
                                  (sides[0] < 0 && !verify[ii].anyInside(_lines)))) {
                                ignored[ii] = 3;
                                log("ignoring unreachable collider:", verify[ii]);
                                break;
                            }
                        }
                    }
                    if (!connected && ignored[ii] == 1 &&
                        ((!BoundData.blockOuter(verify[ii].type) && verify[ii].anyOutside(_lines)) ||
                         (!BoundData.blockInner(verify[ii].type) && verify[ii].anyInside(_lines)))) {
                        ignored[ii] = 4;
                        log("ignoring unconnected collider:", verify[ii]);
                    }
                    if (ignored[ii] == 1) {
                        cd.colliders.push(verify[ii]);
                    }
                }
                for (ii = 0, jj = 0; ii < verify.length; jj++) {
                    if (ignored[jj] == 4) {
                        verify.splice(ii, 1);
                    } else {
                        ii++;
                    }
                }
            }

            // Now check for collisions with dynamic objects
            if (cd.acolliders.length > 0) {
                var averify :Array = cd.acolliders;
                cd.acolliders = new Array();
                for each (var db :DynamicBounds in averify) {
                    var acols :Array = _collider.collide(this, db);
                    if (acols.length > 0 &&
                            (controller.getCollisionHandler(db.controller) != null ||
                             db.controller.getCollisionHandler(controller) != null)) {
                        cd.alines[cd.acolliders.length] = acols;
                        cd.acolliders.push(db);
                    /*
                    } else if (acols.length > 0) {
                        log("no collision handler found for collider");
                    */
                    }
                }
            }
            if (cd.acolliders.length > 0 && cd.colliders.length == 0 && verify.length > 0) {
                verify = new Array();
            } else if (cd.colliders.length > 0 && cd.acolliders.length == 0) {
                averify = new Array();
            }
            if (cd.colliders.length > 0 || cd.acolliders.length > 0) {
                log("reducing delta");
                writeLog();
                cd.fcdX = cdX;
                cd.fcdY = cdY;
                if (Math.abs(cdX) > 1/Metrics.TILE_SIZE || Math.abs(cdY) > 1/Metrics.TILE_SIZE) {
                    cd.colliders = verify;
                }
            } else {
                writeLog();
                translate(cdX, cdY);
                cd.oX += cdX;
                cd.oY += cdY;
                cd.fcdX -= cdX;
                cd.fcdY -= cdY;
                cd.rdelta -= delta;
                if (cd.rdelta == 0) {
                    break;
                }
                if (Math.abs(cdX) > 1/Metrics.TILE_SIZE || Math.abs(cdY) > 1/Metrics.TILE_SIZE) {
                    cd.colliders = verify;
                    cd.acolliders = averify;
                }
            }
            if (cd.colliders.length > 0) {
                //log("found", cd.colliders.length, "colliders, now halving delta, actor (",
                //        actor.x, ",", actor.y, ")");
                didCollide = true;
            } else if (didCollide) {
                //log("no colliders found, now halving delta, actor (", actor.x, ",", actor.y, ")");
            }
            delta /= 2;
        } while (Math.abs(cdX) > 1/Metrics.TILE_SIZE || Math.abs(cdY) > 1/Metrics.TILE_SIZE);

        translate(-cd.oX, -cd.oY);
        //log("actor adjust is (", cd.oX, ",", cd.oY, ") pos (", actor.x, ",", actor.y, ")");

        _resetMLines = true;
        return cd;
    }

    /**
     * Attempts to move an actor on it's current vector for the supplied amount of time.  If the
     * actor collides with any world objects, the actor may get attached to a new ground line,
     * the movement vector may be altered.
     *
     * returns: The remaining time left after the first collision occured.
     */
    public function move (cd :ColliderDetails) :Number
    {
        _hitX = false;
        _hitY = false;
        if (cd == null || cd.colliders == null) {
            log("no cd or colliders");
            return 0;
        }

        //log("translating actor (", cd.oX, ",", cd.oY, ")");
        translate(cd.oX, cd.oY);
        //log("post trans actor pos (", actor.x, ",", actor.y, ")");

        var base :LineData = getBottomLine().clone();
        if (!isNaN(cd.fcdX)) {
            base.translate(cd.fcdX, cd.fcdY);
        }

        // Possibly attach ourselves to a new ground line
        if (cd.colliders.length > 0 && actor.maxWalkable >= 0) {
            log(actor.sprite, "found", cd.colliders.length, "colliders")
            log("base", base);
            log("getBottomLine()", getBottomLine());
            for each (var col :LineData in cd.colliders) {
                log("  " + col);
            }
            var maxY :Number = -1;
            var attached :LineData;
            if (actor.attached != null && actor.attached.xIntersecting(base)) {
                log(actor.sprite, "still hovering attached:", actor.attached, ",", base);
                maxY = Math.max(actor.attached.y1, actor.attached.y2);
                attached = actor.attached;
            }
            var acols :int = 0;
            for each (col in cd.colliders) {
                if (col.ix != 0 &&
                        (col.isIntersecting(base) || col.didSimpleCross(getBottomLine(), base))) {
                    var amax :Number = Math.max(col.y1, col.y2);
                    if (amax > maxY ||
                            (amax == maxY && Math.abs(col.iy) < Math.abs(attached.iy)) ||
                            (attached.yIntersecting(base) && col.yIntersecting(base))) {
                        if (attached != null && Math.abs(col.iy) > actor.maxWalkable &&
                                Math.abs(attached.iy) <= actor.maxWalkable) {
                            continue;
                        }
                        attached = col;
                        maxY = Math.max(col.y1, col.y2);
                    }
                }
            }
            if (attached != null && attached != actor.attached) {
                if (Math.abs(attached.iy) > 0 && actor.y > maxY && cd.colliders.length > 1) {
                    if (attached.y1 == maxY) {
                        attached = pointLine(attached.x1, attached.y1);
                    } else {
                        attached = pointLine(attached.x2, attached.y2);
                    }
                }
                log(actor.sprite, "new attached:", attached, ",", base);
                actor.setAttached(attached);
            }

        // Possibly detach ourselves from our current ground line and possibly automatically
        // attach to a new ground line
        } else if (actor.attached != null) {
            //log("attached:", actor.attached, "bottom:", getBottomLine());
            if (!actor.attached.xIntersecting(getBottomLine()) ||
                (actor.attached.iy > 0 && !actor.attached.yIntersecting(getBottomLine()))) {
                maxY = -1;
                attached = null;
                if (cd.acolliders.length == 0) {
                    for each (var ld :LineData in _collider.getLines(actor)) {
                        if (ld == actor.attached ||
                                ld.isConnected(actor.attached, false) == null ||
                                Math.abs(ld.iy) > actor.maxWalkable ||
                                (ld.y1 > getBottomLine().y1 && ld.y2 > getBottomLine().y1)) {
                            continue;
                        }
                        if ((ld.y1 > maxY || ld.y2 > maxY) && ld.xIntersecting(getBottomLine()) &&
                            ld.getLineDist(getBottomLine()) < MIN_ATTACH_DIST) {
                            attached = ld;
                            maxY = Math.max(ld.y1, ld.y2);
                        }
                    }
                    if (attached != null) {
                        if (actor.attached.iy != 0 && Maths.sign0(attached.iy * attached.ix) !=
                                Maths.sign0(actor.attached.iy * actor.attached.ix) &&
                            Math.abs(attached.iy) > 0 && actor.y > maxY) {
                            if (attached.y1 == maxY) {
                                attached = pointLine(attached.x1, attached.y1);
                            } else {
                                attached = pointLine(attached.x2, attached.y2);
                            }
                        }
                    }
                }
                if (attached == null) {
                    log(actor.sprite, "detached", actor.attached, ",", getBottomLine());
                    //trace(actor.sprite + " detached " + actor.attached + ", " + getBottomLine());
                } else {
                    log(actor.sprite, "autoatached", attached, ",", getBottomLine());
                }
                actor.setAttached(attached);
            }
        }

        // Make any movement vector adjustments based on the remaining collisions
        // First we check any lines that are crossed
        if (cd.colliders.length > 0) {
            for each (col in cd.colliders) {
                if (actor.attached == col ||
                        (col.isConnected(actor.attached, false) != null &&
                            Math.abs(col.iy) < actor.maxWalkable)) {
                    continue;
                }
                if (didCross(col, cd.fcdX, cd.fcdY)) {
                    if (col.iy != 0) {
                        _hitX = true;
                    }
                    if (col.ix != 0) {
                        if (col.xIntersecting(getBottomLine())) {
                            _hitY = true;
                        } else {
                            _hitX = true;
                        }
                    }
                }
            }
        }
        // If no lines were crossed, we next check the intersecting lines
        if (!_hitX && !_hitY && cd.colliders.length > 0) {
            for each (col in cd.colliders) {
                if (actor.attached == col || (col.isConnected(actor.attached, false) != null &&
                            Math.abs(col.iy) < actor.maxWalkable)) {
                    continue;
                }
                if (!didCross(col, cd.fcdX, cd.fcdY)) {
                    if (col.iy != 0) {
                        _hitX = true;
                    }
                    if (col.ix != 0) {
                        if (col.xIntersecting(getBottomLine())) {
                            _hitY = true;
                        } else {
                            _hitX = true;
                        }
                    }
                }
            }
        }
        // update the movement vector
        if (_hitX) {
            actor.dx = 0;
        }
        if (_hitY) {
            actor.dy = 0;
        }
        if (cd.acolliders.length == 0) {
            //log("no dynamic colliders found (", actor.x, ",", actor.y, ")");
        }
        dynamicCollider(cd);

        if (actor.attached != null) {
            var dist :Number = actor.attached.getLineDist(getBottomLine());
            if (dist > MIN_ATTACH_DIST) {
                log(actor.sprite, "detaching:", actor.attached,
                        "dist:", dist, ",", getBottomLine());
                actor.setAttached(null);
            }
        }
        //log("new actor pos (", actor.x, ",", actor.y, ")");
        return cd.rdelta;
    }

    public function collidedWith (ab :SimpleActorBounds, crosslines :Array) :void
    {

    }

    protected function genMovementBounds (cdX :Number, cdY :Number) :void
    {
        var x1 :Number = (cdY < 0 ? cdX : 0);
        var y1 :Number = (cdY < 0 ? cdY : 0);
        var x2 :Number = (cdX < 0 ? cdX : 0);
        var y2 :Number = (cdX < 0 ?
                cdY + (cdY < 0 ? actor.height : 0) : (cdY < 0 ? 0 : actor.height));
        var x3 :Number = (cdY >= 0 ? cdX : 0);
        var y3 :Number = actor.height + (cdY >= 0 ? cdY : 0);
        var x4 :Number = actor.width + (cdY >= 0 ? cdX : 0);
        var y4 :Number = actor.height + (cdY >= 0 ? cdY : 0);
        var x5 :Number = actor.width + (cdX >= 0 ? cdX : 0);
        var y5 :Number = (cdX >= 0 ?
                cdY + (cdY < 0 ? actor.height : 0) : (cdY < 0 ? 0 : actor.height));
        var x6 :Number = actor.width + (cdY < 0 ? cdX : 0);
        var y6 :Number = (cdY < 0 ? cdY : 0);
        //log("new movement bounds (", cdX, ",", cdY, ")");
        if (_mlines == null) {
            _mlines = new Array();
            _mlines.push(dynLD(x1, y1, x2, y2, ACTOR_BOUND));
            _mlines.push(dynLD(x2, y2, x3, y3, ACTOR_BOUND));
            _mlines.push(dynLD(x3, y3, x4, y4, ACTOR_BOUND));
            _mlines.push(dynLD(x4, y4, x5, y5, ACTOR_BOUND));
            _mlines.push(dynLD(x5, y5, x6, y6, ACTOR_BOUND));
            _mlines.push(dynLD(x6, y6, x1, y1, ACTOR_BOUND));
        } else {
            dynUpdateLD(_mlines[0], x1, y1, x2, y2, _resetMLines);
            dynUpdateLD(_mlines[1], x2, y2, x3, y3, _resetMLines);
            dynUpdateLD(_mlines[2], x3, y3, x4, y4, _resetMLines);
            dynUpdateLD(_mlines[3], x4, y4, x5, y5, _resetMLines);
            dynUpdateLD(_mlines[4], x5, y5, x6, y6, _resetMLines);
            dynUpdateLD(_mlines[5], x6, y6, x1, y1, _resetMLines);
        }
        _resetMLines = false;
        /*
        for each (var mline :LineData in _mlines) {
            log("  ", mline);
        }
        */
    }

    protected function inYBounds (line :LineData) :Boolean
    {
        var maxY :Number = Math.max(line.y1, line.y2);
        var minY :Number = Math.min(line.y1, line.y2);
        return (getBottomLine().y1 >= minY && getBottomLine().y1 < maxY + 0.1);
    }

    protected function pointLine (x :Number, y :Number) :LineData
    {
        var ld :LineData = new LineData(x - 0.00001, y, x + 0.00001, y, BoundData.ALL);
        ld.mag = 0.00001;
        ld.ix = 1;
        ld.iy = 0;
        ld.nx = 0;
        ld.ny = 1;
        ld.D = -y;
        return ld;
    }

    protected function log (... data) :void
    {
        if (DEBUG && data != null) {
            if (_buffer != null) {
                _buffer.push(data.join(" "));
            } else {
                trace(data.join(" "));
            }
        }
    }

    protected function flog (... data) :void
    {
        if (actor.id < 100) {
            trace(data.join(" "));
        }
    }

    protected function startLog () :void
    {
        if (DEBUG) {
            _buffer = new Array();
        }
    }

    protected function clearLog () :void
    {
        if (DEBUG) {
            _buffer = null;
        }
    }

    protected function writeLog () :void
    {
        if (DEBUG) {
            if (_buffer != null) {
                for each (var str :String in _buffer) {
                    trace(str);
                }
                _buffer = null;
            }
        }
    }

    //protected var _collider :Collider;

    protected var _lines :Array;
    protected var _mlines :Array;
    protected var _resetMLines :Boolean;
    protected var _hitX :Boolean;
    protected var _hitY :Boolean;
    protected var _log :String;
    protected var _buffer :Array;

    protected static const MIN_ATTACH_DIST :Number = 0.1;

    protected static const ACTOR_BOUND :int = BoundData.ALL & BoundData.S_ALL;
}
}
