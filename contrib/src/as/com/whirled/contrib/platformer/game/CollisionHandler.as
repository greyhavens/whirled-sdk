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

import com.whirled.contrib.platformer.board.ColliderDetails;

import com.threerings.util.env.Environment;

public class CollisionHandler
{
    public function CollisionHandler (c :Class)
    {
        _handledClass = c;
    }

    /**
     * Returns true if this handler handles collisions for this class.
     */
    public function handlesObject (o :Object) :Boolean
    {
        return o is _handledClass;
    }

    /**
     * Returns true if this handler handles subclasses of the supplied handler.
     */
    public function handlesSubclass (ch :CollisionHandler) :Boolean
    {
        return Environment.isAssignableAs(ch._handledClass, _handledClass);
    }

    public function collide (source :Object, target :Object, cd :ColliderDetails) :void
    {
    }

    public function reset () :void
    {
    }

    protected var _handledClass :Class;
}
}
