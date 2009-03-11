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

public class CookiePrototype extends PropertyPrototype
{
    public function CookiePrototype (name :String, cookieType :CookiePropertyType,
        defaultValue :Object = null, playerId :int = 0)
    {
        super(name, playerId);

        _cookieType = cookieType;
        _defaultValue = defaultValue;
    }

    override public function get type () :PropertyType
    {
        return PropertyType.COOKIE;
    }

    public function get cookieType () :CookiePropertyType
    {
        return _cookieType;
    }

    public function get defaultValue () :Object
    {
        return _defaultValue;
    }

    public function createDefaultInstance (mgr :CookieManager) :CookieProperty
    {
        return new _cookieType.cls(mgr, name, defaultValue);
    }

    protected var _cookieType :CookiePropertyType;
    protected var _defaultValue :Object;
}
}
