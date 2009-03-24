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

package com.whirled.contrib.platformer.game {

import com.whirled.contrib.platformer.PlatformerContext;
import com.whirled.contrib.platformer.board.ColliderDetails;
import com.whirled.contrib.platformer.piece.Hover;
import com.whirled.contrib.platformer.net.HoverMessage;

public class HoverCollisionHandler extends CollisionHandler
{
    public function HoverCollisionHandler (hc :HoverController)
    {
        super(ActorController);
        _hover = hc.getDynamic() as Hover;
    }

    override public function handlesObject (o :Object) :Boolean
    {
        return super.handlesObject(o) && _collided.indexOf(o) == -1;
    }

    override public function collide (source :Object, target :Object, cd :ColliderDetails) :void
    {
        if (_hover.amOwner()) {
            _hover.hovered = true;
        } else {
            PlatformerContext.net.sendMessage(HoverMessage.create(HoverMessage.HOVER, _hover.id));
        }
        _collided.push(target.controller);
    }

    override public function reset () :void
    {
        if (_collided.length > 0) {
            _collided.splice(0);
        } else if (_hover.amOwner()) {
            _hover.hovered = false;
        } else {
            PlatformerContext.net.sendMessage(HoverMessage.create(HoverMessage.UNHOVER, _hover.id));
        }
    }

    protected var _hover :Hover;
    protected var _collided :Array = new Array();
}
}
