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

import com.threerings.util.Enum;
import com.threerings.util.HashMap;

public class PersistUtil
{
    public static function serializeHashMap (bytes :ByteArray, map :HashMap,
        serializeKey :Function, serializeValue :Function) :void
    {
        bytes.writeInt(map.size());
        for each (var key :Object in map.keys()) {
            serializeKey(key);
            serializeValue(map.get(key));
        }
    }

    public static function serializeEnumIntMap (bytes :ByteArray, map :HashMap) :void
    {
        serializeHashMap(map, bytes, serializeEnum, serializeInt);
    }

    public static function serializeEnumStringMap (bytes :ByteArray, map :HashMap) :void
    {
        serializeHashMap(map, bytes, seralizeEnum, serializeString);
    }

    public static function serializeEnum (bytes :ByteArray, value :Enum) :void
    {
        bytes.writeUTF(value.name());
    }

    public static function serializeInt (bytes :ByteArray, value :int) :void
    {
        bytes.writeInt(value);
    }

    public static function serializeString (bytes :ByteArray, value :String) :void
    {
        bytes.writeUTF(value);
    }

    public static function deserializeHashMap (bytes :ByteArray, deserializeKey :Function,
        deserializeValue :Function) :HashMap
    {
        var map :HashMap = new HashMap();
        var size :int = bytes.readInt();
        for (var ii :int = 0; ii < size; ii++) {
            var key :Object = deserializeKey(bytes);
            var value :Object = deserializeValue(bytes);
            map.put(key, value);
        }
        return map;
    }

    public static function deserializeEnumIntMap (keyEnum :Class) :Function
    {
        return function (bytes :ByteArray) :HashMap {
            return deserializeHashMap(bytes, deserializeEnum(keyEnum), deserializeInt);
        };
    }

    public static function deserializeEnumStringMap (keyEnum :Class) :Function
    {
        return function (bytes :ByteArray) :HashMap {
            return deserializeHashMap(bytes, deserializeEnum(keyEnum), deserializeString);
        }
    }

    public static function deserializeEnum (enum :Class) :Function
    {
        return function (bytes :ByteArray) :Object {
            return Enum.valueOf(enum, bytes.readUTF());
        };
    }

    public static function deserializeInt (bytes :ByteArray) :int
    {
        return bytes.readInt();
    }

    public static function deserializeString (bytes :ByteArray) :String
    {
        return bytes.readUTF();
    }
}
}
