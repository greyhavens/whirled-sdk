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

import com.whirled.contrib.platformer.game.CollisionHandler;
import com.whirled.contrib.platformer.game.DynamicController;
import com.whirled.contrib.platformer.piece.Dynamic;
import com.whirled.contrib.platformer.piece.Rect;

public class DynamicBounds
{
    public var controller :DynamicController;
    public var dyn :Dynamic;

    public function DynamicBounds (dc :DynamicController, c :Collider)
    {
        controller = dc;
        dyn = dc.getDynamic();
        _collider = c;
        _rect = new Rect(dyn.x, dyn.y);
    }

    public function updateBounds () :void
    {
    }

    /**
     * Translates the actor and updates all the boundary data.
     */
    public function translate (dX :Number, dY :Number) :void
    {
        dyn.x += dX;
        dyn.y += dY;
        _rect.x = dyn.x;
        _rect.y = dyn.y;
    }

    public function getRect () :Rect
    {
        return _rect;
    }

    public function getInteractingBounds () :Array
    {
        var abounds :Array = new Array();
        if (_collider.doesInteract(dyn.inter, Dynamic.GLOBAL)) {
            checkAndPush(abounds, _collider.getDynamicBoundsByType(Dynamic.GLOBAL));
            //abounds = abounds.concat(_collider.getDynamicBoundsByType(Dynamic.GLOBAL));
        }
        if (_collider.doesInteract(dyn.inter, Dynamic.ENEMY)) {
            checkAndPush(abounds, _collider.getDynamicBoundsByType(Dynamic.ENEMY));
            //abounds = abounds.concat(_collider.getDynamicBoundsByType(Dynamic.ENEMY));
        }
        if (_collider.doesInteract(dyn.inter, Dynamic.PLAYER)) {
            checkAndPush(abounds, _collider.getDynamicBoundsByType(Dynamic.PLAYER));
            //abounds = abounds.concat(_collider.getDynamicBoundsByType(Dynamic.PLAYER));
        }
        return abounds;
    }

    public function checkAndPush (dest :Array, source :Array) :void
    {
        for each (var db :DynamicBounds in source) {
            if (isInteresting(db)) {
                dest.push(db);
            }
        }
    }

    public function isInteresting (db :DynamicBounds) :Boolean
    {
        return _collider.isInteresting(this, db);
    }

    public function updatedDB (cd :ColliderDetails, db :DynamicBounds) :Boolean
    {
        if (cd != null && db != null) {
            if (_collider.doesInteract(dyn.inter, db.dyn.inter) && isInteresting(db)) {
                return cd.pushActor(db);
            }
            /*
            var c :int = cd.colliders.length;
            var a :int = (cd.acolliders == null ? 0 : cd.acolliders.length);
            if (c + a > 0) {
                trace("updatedDB to " + c + " and " + a);
            }
            */
        }
        return true;
    }

    protected function dynamicCollider (cd :ColliderDetails) :void
    {
        if (cd.acolliders == null || cd.acolliders.length == 0) {
            return;
        }

        for (var ii :int = 0; ii < cd.acolliders.length; ii++) {
            var ch :CollisionHandler =
                controller.getCollisionHandler(cd.acolliders[ii].controller);
            var reset :Boolean = false;
            if (ch != null) {
                ch.collide(this, cd.acolliders[ii], cd);
                reset = true;
            }
            ch = cd.acolliders[ii].controller.getCollisionHandler(controller);
            if (ch != null) {
                ch.collide(cd.acolliders[ii], this, cd);
                reset = true;
            }
            if (reset) {
                //trace("resetting " + cd.acolliders[ii].controller.getDynamic().id + " due to collision with " + dyn.id);
                cd.acolliders[ii].controller.getTask().reset();
            }
        }
    }

    protected function dynLD (x1 :Number, y1 :Number, x2 :Number, y2 :Number, type :int) :LineData
    {
        return new LineData(dyn.x + x1, dyn.y + y1, dyn.x + x2, dyn.y + y2, type);
    }

    protected function dynUpdateLD (line :LineData, x1 :Number, y1 :Number, x2 :Number, y2 :Number,
            reset :Boolean = false) :void
    {
        line.update(dyn.x + x1, dyn.y + y1, dyn.x + x2, dyn.y + y2, reset);
    }

    protected var _collider :Collider;
    protected var _rect :Rect;
}
}
