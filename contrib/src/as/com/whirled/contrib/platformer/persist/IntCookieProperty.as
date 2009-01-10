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

public class IntCookieProperty extends CookieProperty
{
    public function IntCookieProperty (manager :CookieManager, name :String = null, 
        defaultValue :Object = null)
    {
        super (manager, name);

        // This should not simply call value = defaultValue because the value setter tells the 
        // CookieManager that this property was updated, and a new version was pushed out, but 
        // we don't want to push default values out in the cookie.
        if (!(defaultValue is int)) {
            throw new Error("IntCookieProperty can only accept int values [" + value + "]");
        }
        _value = defaultValue;
    }

    override public function set value (value :Object) :void
    {
        if (!(value is int)) {
            throw new Error("IntCookieProperty can only accept int values [" + value + "]");
        }

        super.value = value;
    }

    override public function get typeId () :int
    {
        return CookiePropertyType.INT.id;
    }

    /**
     * Typed accessor for easy arithmetic operations.
     */
    public function get intValue () :int
    {
        return value as int;
    }

    /**
     * Typed accessor for easy arithmetic operations.
     */
    public function set intValue (intValue :int) :void
    {
        value = intValue;
    }

    override public function serialize (bytes :ByteArray) :void
    {
        bytes.writeUTF(_name);
        bytes.writeInt(_value as int);
    }

    override public function deserialize (bytes :ByteArray) :void
    {
        _name = bytes.readUTF();
        _value = bytes.readInt();
    }
}
}
