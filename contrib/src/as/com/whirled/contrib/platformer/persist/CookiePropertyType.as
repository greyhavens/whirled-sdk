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

package com.whirled.contrib.platformer.persist {

import com.threerings.util.Enum;

public final class CookiePropertyType extends Enum
{
    public static const INT :CookiePropertyType =
        new CookiePropertyType("INT", 1, IntCookieProperty);
    public static const STRING :CookiePropertyType =
        new CookiePropertyType("STRING", 2, StringCookieProperty);
    finishedEnumerating(CookiePropertyType);

    public static function valueOf (name :String) :CookiePropertyType
    {
        return Enum.valueOf(CookiePropertyType, name) as CookiePropertyType;
    }

    public static function values () :Array
    {
        return Enum.values(CookiePropertyType);
    }

    public static function getClass (id :int) :Class
    {
        for each (var propertyType :CookiePropertyType in values()) {
            if (id == propertyType.id) {
                return propertyType.cls;
            }
        }

        throw new Error("CookiePropertyType id not found! [" + id + "]");
    }

    public function get id () :int
    {
        return _id;
    }

    public function get cls () :Class
    {
        return _class;
    }

    // @private
    public function CookiePropertyType (name :String, id :int, cls :Class)
    {
        super(name);
        _id = id;
        _class = cls;
    }

    protected var _id :int;
    protected var _class :Class;
}
}
