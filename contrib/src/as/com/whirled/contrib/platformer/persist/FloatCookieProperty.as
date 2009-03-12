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

public class FloatCookieProperty extends CookiePropertyBase
{
    public function FloatCookieProperty (manager :CookieManager, typeId :int, name :String = null,
        defaultValue :Object = null)
    {
        super(manager, typeId, name);

        if (defaultValue != null && !(defaultValue is Number)) {
            throw new Error("FloatCookieProperty can only accept Number values [" + value + "]");
        }
        _value = defaultValue;
    }

    override public function set value (value :Object) :void
    {
        if (!(value is Number)) {
            throw new Error("FloatCookieProperty can only accept Number values [" + value + "]");
        }

        super.value = value;
    }

    public function get floatValue () :Number
    {
        return value as Number;
    }

    public function set floatValue (floatValue :Number) :void
    {
        value = floatValue;
    }

    override public function serialize (bytes :ByteArray) :void
    {
        bytes.writeUTF(_name);
        bytes.writeFloat(_value as Number);
    }

    override public function deserialize (bytes :ByteArray) :void
    {
        _name = bytes.readUTF();
        _value = bytes.readFloat();
    }
}
}
