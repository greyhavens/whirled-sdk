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

import com.whirled.contrib.platformer.game.ActorController;
import com.whirled.contrib.platformer.piece.Actor;
import com.whirled.contrib.platformer.piece.Rect;

public class ActorBounds extends DynamicBounds
{
    public var actor :Actor;

    public function ActorBounds (ac :ActorController, c :Collider)
    {
        super(ac, c);
        actor = ac.getActor();
    }

    override public function getRect () :Rect
    {
        return new Rect(actor.x, actor.y, actor.width, actor.height);
    }
}
}
