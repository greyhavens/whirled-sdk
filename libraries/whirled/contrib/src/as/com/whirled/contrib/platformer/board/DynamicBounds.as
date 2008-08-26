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

public class DynamicBounds
{
    public var controller :DynamicController;
    public var dyn :Dynamic;

    public function DynamicBounds (dc :DynamicController, c :Collider)
    {
        controller = dc;
        dyn = dc.getDynamic();
        _collider = c;
    }

    /**
     * Translates the actor and updates all the boundary data.
     */
    public function translate (dX :Number, dY :Number) :void
    {
        dyn.x += dX;
        dyn.y += dY;
    }

    public function getInteractingBounds () :Array
    {
        var abounds :Array = new Array();
        if (dyn.inter == Dynamic.DEAD) {
            return abounds;
        }
        abounds = abounds.concat(_collider.getDynamicBoundsByType(Dynamic.GLOBAL));
        if (dyn.inter == Dynamic.PLAYER) {
            abounds = abounds.concat(_collider.getDynamicBoundsByType(Dynamic.ENEMY));
        } else if (dyn.inter == Dynamic.ENEMY) {
            abounds = abounds.concat(_collider.getDynamicBoundsByType(Dynamic.PLAYER));
        }
        return abounds;
    }

    protected function dynamicCollider (cd :ColliderDetails) :void
    {
        if (cd.acolliders == null || cd.acolliders.length == 0) {
            return;
        }

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

    protected var _collider : Collider;
}
}
