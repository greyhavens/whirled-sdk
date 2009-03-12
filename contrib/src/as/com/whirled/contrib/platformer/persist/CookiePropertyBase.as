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

import flash.utils.ByteArray;

import com.threerings.util.ClassUtil;

public /* abstract */ class CookiePropertyBase
    implements CookieProperty
{
    public function CookiePropertyBase (manager :CookieManager, typeId :int, name :String)
    {
        _manager = manager;
        _name = name;
        _typeId = typeId;
    }

    // from PersistentProperty
    public function get name () :String
    {
        return _name;
    }

    // from PersistentProperty
    public function get value () :Object
    {
        return _value;
    }

    // from CookieProperty
    public function get typeId () :int
    {
        return _typeId;
    }

    // from CookieProperty
    public function set value (value :Object) :void
    {
        _value = value;
        _manager.cookiePropertyUpdated(this);
    }

    public function toString () :String
    {
        return ClassUtil.tinyClassName(this) + " [name=" + _name + ", value=" + value + "]";
    }

    // from CookieProperty
    public /* abstract */ function serialize (bytes :ByteArray) :void
    {
        throw new Error("seralize in CookieProperty is abstract!");
    }

    // from CookieProperty
    public /* abstract */ function deserialize (bytes :ByteArray) :void
    {
        throw new Error("deserialize in CookieProperty is abstract!");
    }

    protected var _manager :CookieManager;
    protected var _name :String;
    protected var _typeId :int;
    protected var _value :Object = null;
}
}
