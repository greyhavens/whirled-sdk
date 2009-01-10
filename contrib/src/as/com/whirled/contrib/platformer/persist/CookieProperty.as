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

public class CookieProperty extends PersistentProperty
{
    public function CookieProperty (manager :CookieManager, name :String)
    {
        super(name);
        _manager = manager;
    }

    override public function get value () :Object
    {
        return _value;
    }

    public function set value (value :Object) :void
    {
        _value = value;
        _manager.cookiePropertyUpdated(this);
    }

    public /* abstract */ function get typeId () :int
    {
        throw new Error("get typeId in CookieProperty is abstract!");
    }

    public /* abstract */ function serialize (bytes :ByteArray) :void
    {
        throw new Error("seralize in CookieProperty is abstract!");
    }

    public /* abstract */ function deserialize (bytes :ByteArray) :void
    {
        throw new Error("deserialize in CookieProperty is abstract!");
    }

    protected var _manager :CookieManager;
    protected var _value :Object = null;
}
}
