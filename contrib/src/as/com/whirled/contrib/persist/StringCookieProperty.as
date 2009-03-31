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

package com.whirled.contrib.persist {

import flash.utils.ByteArray;

public class StringCookieProperty extends CookiePropertyBase
{
    public function StringCookieProperty (manager :CookieManager, typeId :int, name :String = null,
        defaultValue :Object = null)
    {
        super(manager, typeId, name);

        if (defaultValue != null && !(defaultValue is String)) {
            throw new Error("StringCookieProperty can only accept String values [" +
                defaultValue + "]");
        }
        _value = defaultValue;
    }

    override public function set value (value :Object) :void
    {
        if (!(value is String)) {
            throw new Error("StringCookieProperty can only accept String values [" + value + "]");
        }

        super.value = value;
    }

    public function get stringValue () :String
    {
        return value as String;
    }

    override public function serialize (bytes :ByteArray) :void
    {
        bytes.writeUTF(_name);
        bytes.writeUTF(stringValue);
    }

    override public function deserialize (bytes :ByteArray) :void
    {
        _name = bytes.readUTF();
        _value = bytes.readUTF();
    }
}
}
