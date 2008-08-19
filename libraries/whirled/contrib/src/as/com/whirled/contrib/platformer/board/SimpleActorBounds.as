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
import com.whirled.contrib.platformer.util.Maths;

import com.whirled.contrib.platformer.display.Metrics;
import com.whirled.contrib.platformer.game.ActorController;
import com.whirled.contrib.platformer.game.CollisionHandler;

/**
 * Provides collision detection support for an actor that has an axis aligned rectangular bounding
 * box.
 */
public class SimpleActorBounds
{
    public var controller :ActorController;
    public var actor :Actor;
    public var lines :Array = new Array();

    public static const DEBUG :Boolean = false;

    public function SimpleActorBounds (ac :ActorController, c :Collider)
    {
        controller = ac;
        actor = ac.getActor();
        lines.push(new LineData(actor.x, actor.y, actor.x, actor.y+actor.height, ACTOR_BOUND));
        lines.push(new LineData(actor.x, actor.y+actor.height, actor.x+actor.width,
                actor.y+actor.height, ACTOR_BOUND));
        lines.push(new LineData(actor.x+actor.width, actor.y+actor.height, actor.x+actor.width,
                actor.y, ACTOR_BOUND));
        lines.push(new LineData(actor.x+actor.width, actor.y, actor.x, actor.y, ACTOR_BOUND));
        _collider = c;
    }

    /**
     * Translates the actor and updates all the boundary data.
     */
    public function translate (dX :Number, dY :Number) :void
    {
        actor.x += dX;
        actor.y += dY;
        for each (var ld :LineData in lines) {
            ld.translate(dX, dY);
        }
    }

    /**
     * Returns an array of colliding lines from the other actor.
     */
    public function collide (ab :SimpleActorBounds, mlines :Array) :Array
    {
        var cols :Array = new Array();
        /*
        if (simpleCollide(ab)) {
            return cols;
        }
        */
        for each (var line :LineData in ab.lines) {
            if (line.polyIntersecting(mlines)) {
                cols.push(line);
            }
        }
        return cols;
    }

    /**
     * Returns true if these actors are colliding.
     */
    public function simpleCollide (ab :SimpleActorBounds) :Boolean
    {
        return simpleCollideLines (ab.lines);
    }

    public function simpleCollideLines (olines :Array) :Boolean
    {
        for each (var line :LineData in lines) {
            if (line.polyIntersecting(olines)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Returns true if any of the actor bounds crosses the line after the translation.
     */
    public function didCross (ld :LineData, xd :Number, yd :Number) :Boolean
    {
        for each (var line :LineData in lines) {
            if (ld.didCrossDelta(line, xd, yd)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Returns an array of crossing lines.
     */
    public function crossers (ld :LineData, xd :Number, yd :Number) :Array
    {
        var ret :Array = new Array();
        for each (var line :LineData in lines) {
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
        for each (var line :LineData in lines) {
            if (((sides[0] > 0 && ld0.isOutside(line.x1, line.y1)) ||
                 (sides[0] < 0 && ld0.isInside(line.x1, line.y1))) && (
                 (sides[1] > 0 && ld1.isOutside(line.x1, line.y1)) ||
                 (sides[1] < 0 && ld1.isInside(line.x1, line.y1)))) {
                return true;
            }
        }
        return false;
    }

    public function getInteractingActorBounds () :Array
    {
        var abounds :Array = new Array();
        if (actor.inter == Dynamic.DEAD) {
            return abounds;
        }
        abounds = abounds.concat(_collider.getActorBoundsByType(Dynamic.GLOBAL));
        if (actor.inter == Dynamic.PLAYER) {
            abounds = abounds.concat(_collider.getActorBoundsByType(Dynamic.ENEMY));
        } else if (actor.inter == Dynamic.ENEMY) {
            abounds = abounds.concat(_collider.getActorBoundsByType(Dynamic.PLAYER));
        }
        return abounds;
    }

    public function findColliders (delta :Number, cd :ColliderDetails = null) :ColliderDetails
    {
        if (delta <= 0) {
            return new ColliderDetails(null, null, 0);
        }
        var mlines :Array;
        if (cd == null || cd.colliders == null) {
            cd = new ColliderDetails(_collider.getLines(actor), getInteractingActorBounds(), delta);
        } else {
            cd.setActors(getInteractingActorBounds());
            cd.rdelta = delta;
        }
        var logs :String = "";
        var beforeX :Number = actor.x;
        var beforeY :Number = actor.y;
        var didCollide :Boolean = false;

        do {
            var cdX :Number = actor.dx * delta;
            var cdY :Number = actor.dy * delta;
            var verify :Array = new Array();
            mlines = genMovementBounds(mlines, cdX, cdY);

            // Find all the static lines we collide with
            if (cd.colliders.length > 0) {
                verify = cd.colliders;
                cd.colliders = new Array();
                for each (var ld :LineData in verify) {
                    if (actor.attached == ld || !BoundData.doesBound(ld.type, actor.projCollider)) {
                        continue;
                    }
                    if (ld.polyIntersecting(mlines))  {
                        cd.colliders.push(ld);
                        //log("adding intersecting " + ld);
                    } else {
                        //log("ignoring non intersecting " + ld);
                    }
                }
            }

            // Filter out those lines which don't block our movement direction
            if (cd.colliders.length > 0) {
                logs = "";
                verify = cd.colliders;
                cd.colliders = new Array();
                var ignored :Array = new Array();
                for (var ii :int = 0; ii < verify.length; ii++) {
                    if (!BoundData.doesBound(verify[ii].type)) {
                        cd.colliders.push(verify[ii]);
                        logs += "ignoring non bounding collider: " + verify[ii] + "\n";
                        continue;
                    }
                    var ignore :Boolean = false;
                    var connected :Boolean = false;
                    for (var jj :int = 0; jj < verify.length; jj++) {
                        if (ii == jj) {
                            continue;
                        }
                        var sides :Array = verify[ii].isConnected(verify[jj]);
                        if (sides != null) {
                            connected = true;
                            if (BoundData.getNormalBound(verify[ii].type) != BoundData.ALL &&
                                    isContained(verify[ii], verify[jj], sides)) {
                                ignored[ii] = true;
                                logs += "ignoring contained collider: " + verify[ii] + "\n";
                                break;
                            }
                            if (((sides[1] > 0 && !verify[jj].anyOutside(lines)) ||
                                 (sides[1] < 0 && !verify[jj].anyInside(lines))) &&
                                !((sides[0] > 0 && !verify[ii].anyOutside(lines)) ||
                                  (sides[0] < 0 && !verify[ii].anyInside(lines)))) {
                                ignored[ii] = true;
                                logs += "ignoring unreachable collider: " + verify[ii] + "\n";
                                break;
                            }
                        }
                    }
                    if (!connected && !ignored[ii] &&
                        ((!BoundData.blockOuter(verify[ii].type) && verify[ii].anyOutside(lines)) ||
                         (!BoundData.blockInner(verify[ii].type) && verify[ii].anyInside(lines)))) {
                        ignored[ii] = true;
                        logs += "ignoring unconnected collider: " + verify[ii] + "\n";
                    }
                    if (!ignored[ii]) {
                        cd.colliders.push(verify[ii]);
                    }
                }
            }

            // Now check for collisions with dynamic objects
            if (cd.acolliders != null && cd.acolliders.length > 0) {
                var averify :Array = cd.acolliders;
                cd.acolliders = new Array();
                for each (var ab :SimpleActorBounds in averify) {
                    var acols :Array = collide(ab, mlines);
                    if (acols.length > 0 &&
                            (controller.getCollisionHandler(ab.controller) != null ||
                             ab.controller.getCollisionHandler(controller) != null)) {
                        cd.alines[cd.acolliders.length] = acols;
                        cd.acolliders.push(ab);
                    }
                }
            }
            if (cd.acolliders != null && cd.acolliders.length > 0 &&
                    cd.colliders.length == 0 && verify.length > 0) {
                verify = new Array();
            } else if (cd.colliders.length > 0 && cd.acolliders != null &&
                    cd.acolliders.length == 0) {
                averify = new Array();
            }
            if (cd.colliders.length > 0 || (cd.acolliders != null && cd.acolliders.length > 0)) {
                cd.fcdX = cdX;
                cd.fcdY = cdY;
            } else {
                translate(cdX, cdY);
                cd.oX += cdX;
                cd.oY += cdY;
                cd.fcdX -= cdX;
                cd.fcdY -= cdY;
                cd.rdelta -= delta;
                if (cd.rdelta == 0) {
                    break;
                }
                cd.colliders = verify;
                cd.acolliders = averify;
            }
            if (logs != "") {
                log(logs);
            }
            if (cd.colliders.length > 0) {
                //log("found " + cd.colliders.length + " colliders, now halving delta, actor (" +
                //        actor.x + ", " + actor.y + ")");
                didCollide = true;
            } else if (didCollide) {
                //log("no colliders found, now halving delta, actor (" +
                //    actor.x + ", " + actor.y + ")");
            }
            delta /= 2;
        } while (Math.abs(cdX) > 1/Metrics.TILE_SIZE || Math.abs(cdY) > 1/Metrics.TILE_SIZE);

        translate(-cd.oX, -cd.oY);
        log("actor adjust is (" + cd.oX + ", " + cd.oY + ")");

        if (logs != "") {
            log(logs);
        }
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
        if (cd == null || cd.colliders == null) {
            return 0;
        }

        translate(cd.oX, cd.oY);

        var base :LineData = lines[3].clone();
        if (!isNaN(cd.fcdX)) {
            base.translate(cd.fcdX, cd.fcdY);
        }

        // Possibly attach ourselves to a new ground line
        if (cd.colliders.length > 0 && actor.maxWalkable >= 0) {
            log(actor.sprite + " found " + cd.colliders.length + " colliders");
            for each (var col :LineData in cd.colliders) {
                log("  " + col);
            }
            var maxY :Number = -1;
            var attached :LineData;
            if (actor.attached != null && actor.attached.xIntersecting(base)) {
                log(actor.sprite + " still hovering attached: " + actor.attached + ", " + base);
                maxY = Math.max(actor.attached.y1, actor.attached.y2);
                attached = actor.attached;
            }
            for each (col in cd.colliders) {
                if (Math.abs(col.ix) > 0 &&
                        (col.isIntersecting(base) || col.didCross(lines[3], base))) {
                    if (col.y1 > maxY || col.y2 > maxY || (
                            ((col.y1 == maxY || col.y2 == maxY) &&
                            Math.abs(col.iy) < Math.abs(attached.iy))) ||
                            (attached.yIntersecting(base) && col.yIntersecting(base))) {
                        if (attached != null && Math.abs(col.iy) > actor.maxWalkable) {
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
                        attached = new LineData(attached.x1 - 0.00001, attached.y1,
                            attached.x1 + 0.00001, attached.y1, BoundData.ALL);
                    } else {
                        attached = new LineData(attached.x2 - 0.00001, attached.y2,
                            attached.x2 + 0.00001, attached.y2, BoundData.ALL);
                    }
                }
                log(actor.sprite + " new attached: " + attached + ", " + base);
                actor.attached = attached;
            }

        // Possibly detach ourselves from our current ground line and possibly automatically
        // attach to a new ground line
        } else if (actor.attached != null) {
            //log("attached: " + actor.attached + " bottom: " + lines[3]);
            if (!actor.attached.xIntersecting(lines[3]) ||
                (actor.attached.iy > 0 && !actor.attached.yIntersecting(lines[3]))) {
                maxY = -1;
                attached = null;
                if (cd.acolliders == null || cd.acolliders.length == 0) {
                    for each (var ld :LineData in _collider.getLines(actor)) {
                        if (ld == actor.attached || ld.isConnected(actor.attached, false) == null ||
                            Math.abs(ld.iy) > actor.maxWalkable ||
                            (ld.y1 > lines[3].y1 && ld.y2 > lines[3].y1)) {
                            continue;
                        }
                        if ((ld.y1 > maxY || ld.y2 > maxY) && ld.xIntersecting(lines[3]) &&
                            ld.getLineDist(lines[3]) < MIN_ATTACH_DIST) {
                            attached = ld;
                            maxY = Math.max(ld.y1, ld.y2);
                        }
                    }
                    if (attached != null) {
                        if (Maths.sign0(attached.iy * attached.ix) !=
                                Maths.sign0(actor.attached.iy * actor.attached.ix) &&
                            Math.abs(attached.iy) > 0 && actor.y > maxY) {
                            if (attached.y1 == maxY) {
                                attached = new LineData(attached.x1 - 0.00001, attached.y1,
                                    attached.x1 + 0.00001, attached.y1, BoundData.ALL);
                            } else {
                                attached = new LineData(attached.x2 - 0.00001, attached.y2,
                                    attached.x2 + 0.00001, attached.y2, BoundData.ALL);
                            }
                        }
                    }
                }
                if (attached == null) {
                    log(actor.sprite + " detached " + actor.attached + ", " + lines[3]);
                } else {
                    log(actor.sprite + " autoatached " + attached + ", " + lines[3]);
                }
                actor.attached = attached;
            }
        }

        // Make any movement vector adjustments based on the remaining collisions
        var hitX :Boolean = false;
        var hitY :Boolean = false;
        // First we check any lines that are crossed
        if (cd.colliders.length > 0) {
            for each (col in cd.colliders) {
                if (actor.attached == col || (col.isConnected(actor.attached, false) != null &&
                            Math.abs(col.iy) < actor.maxWalkable)) {
                    continue;
                }
                if (didCross(col, cd.fcdX, cd.fcdY)) {
                    if (col.iy != 0) {
                        hitX = true;
                    }
                    if (col.ix != 0) {
                        if (col.xIntersecting(lines[3])) {
                            hitY = true;
                        } else {
                            hitX = true;
                        }
                    }
                }
            }
        }
        // If no lines were crossed, we next check the intersecting lines
        if (!hitX && !hitY && cd.colliders.length > 0) {
            for each (col in cd.colliders) {
                if (actor.attached == col || (col.isConnected(actor.attached, false) != null &&
                            Math.abs(col.iy) < actor.maxWalkable)) {
                    continue;
                }
                if (!didCross(col, cd.fcdX, cd.fcdY)) {
                    if (col.iy != 0) {
                        hitX = true;
                    }
                    if (col.ix != 0) {
                        if (col.xIntersecting(lines[3])) {
                            hitY = true;
                        } else {
                            hitX = true;
                        }
                    }
                }
            }
        }
        // update the movement vector
        if (hitX) {
            actor.dx = 0;
        }
        if (hitY) {
            actor.dy = 0;
        }
        actorCollider(cd);

        if (actor.attached != null) {
            var dist :Number = actor.attached.getLineDist(lines[3]);
            if (dist > MIN_ATTACH_DIST) {
                log(actor.sprite + " detaching: " + actor.attached + " dist: " + dist +
                        ", " + lines[3]);
                actor.attached = null;
            }
        }
        log("new actor pos (" + actor.x + ", " + actor.y + ")");
        return cd.rdelta;
    }

    public function collidedWith (ab :SimpleActorBounds, crosslines :Array) :void
    {

    }

    protected function actorCollider (cd :ColliderDetails) :void
    {
        if (cd.acolliders == null || cd.acolliders.length == 0) {
            return;
        }
        var ay :Number = 0;
        var ax :Number = 0;
        var day :Number = 0;
        var dax :Number = 0;

        for (var ii :int = 0; ii < cd.acolliders.length; ii++) {
            var ch :CollisionHandler =
                controller.getCollisionHandler(cd.acolliders[ii].controller);
            if (ch != null) {
                ch.collide(this, cd.acolliders[ii], cd);
            }
            ch = cd.acolliders[ii].controller.getCollisionHandler(controller);
            if (ch != null) {
                ch.collide(cd.acolliders[ii], this, cd);
            }
        }
    }

    protected function genMovementBounds (mlines :Array, cdX :Number, cdY :Number) :Array
    {
        var x1 :Number = actor.x + (cdY < 0 ? cdX : 0);
        var y1 :Number = actor.y + (cdY < 0 ? cdY : 0);
        var x2 :Number = actor.x + (cdX < 0 ? cdX : 0);
        var y2 :Number = actor.y + (cdX < 0 ?
                cdY + (cdY < 0 ? actor.height : 0) : (cdY < 0 ? 0 : actor.height));
        var x3 :Number = actor.x + (cdY >= 0 ? cdX : 0);
        var y3 :Number = actor.y + actor.height + (cdY >= 0 ? cdY : 0);
        var x4 :Number = actor.x + actor.width + (cdY >= 0 ? cdX : 0);
        var y4 :Number = actor.y + actor.height + (cdY >= 0 ? cdY : 0);
        var x5 :Number = actor.x + actor.width + (cdX >= 0 ? cdX : 0);
        var y5 :Number = actor.y + (cdX >= 0 ?
                cdY + (cdY < 0 ? actor.height : 0) : (cdY < 0 ? 0 : actor.height));
        var x6 :Number = actor.x + actor.width + (cdY < 0 ? cdX : 0);
        var y6 :Number = actor.y + (cdY < 0 ? cdY : 0);
        //log("new movement bounds (" + cdX + ", " + cdY + ")");
        if (mlines == null) {
            mlines = new Array();
            mlines.push(new LineData(x1, y1, x2, y2, ACTOR_BOUND));
            mlines.push(new LineData(x2, y2, x3, y3, ACTOR_BOUND));
            mlines.push(new LineData(x3, y3, x4, y4, ACTOR_BOUND));
            mlines.push(new LineData(x4, y4, x5, y5, ACTOR_BOUND));
            mlines.push(new LineData(x5, y5, x6, y6, ACTOR_BOUND));
            mlines.push(new LineData(x6, y6, x1, y1, ACTOR_BOUND));
        } else {
            mlines[0].update(x1, y1, x2, y2);
            mlines[1].update(x2, y2, x3, y3);
            mlines[2].update(x3, y3, x4, y4);
            mlines[3].update(x4, y4, x5, y5);
            mlines[4].update(x5, y5, x6, y6);
            mlines[5].update(x6, y6, x1, y1);
        }
        /*
        for each (var mline :LineData in mlines) {
            log("  " + mline);
        }
        */
        return mlines;
    }

    protected function inYBounds (line :LineData) :Boolean
    {
        var maxY :Number = Math.max(line.y1, line.y2);
        var minY :Number = Math.min(line.y1, line.y2);
        return (lines[3].y1 >= minY && lines[3].y1 < maxY + 0.1);
    }

    protected function log (str :String) :void
    {
        if (DEBUG) {
            trace(str);
        }
    }

    protected var _collider :Collider;

    protected static const MIN_ATTACH_DIST :Number = 0.1;

    protected static const ACTOR_BOUND :int = BoundData.ALL & BoundData.S_ALL;
}
}
