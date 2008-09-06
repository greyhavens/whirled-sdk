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

package com.whirled.contrib.platformer.piece {

import com.threerings.util.Hashable;

/**
 * Base class for any object that can move in the world.
 */
public class Dynamic
    implements Hashable
{
    public static const GLOBAL :int = 0;
    public static const PLAYER :int = 1;
    public static const ENEMY :int = 2;
    public static const DEAD :int = 3;

    public var x :Number = 0;
    public var y :Number = 0;
    public var dx :Number = 0;
    public var dy :Number = 0;

    public var id :int;

    public var inter :int;

    public var sprite :String;

    public function Dynamic (insxml :XML = null)
    {
        if (insxml != null) {
            x = insxml.@x;
            y = insxml.@y;
            id = insxml.@id;
        }
    }

    public function xmlInstance () :XML
    {
        var xml :XML = <dynamicdef/>;
        xml.@x = x;
        xml.@y = y;
        xml.@id = id;
        return xml;
    }

    public function hashCode () :int
    {
        return id;
    }

    public function equals (other :Object) :Boolean
    {
        return (other is Dynamic && (other as Dynamic).id == id);
    }

    public function getBounds () :Rect
    {
        return new Rect(x, y);
    }
}
}
