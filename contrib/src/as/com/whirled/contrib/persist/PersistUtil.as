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

import flash.utils.IDataInput;
import flash.utils.IDataOutput;

import com.threerings.util.ClassUtil;
import com.threerings.util.Enum;
import com.threerings.util.Map;
import com.threerings.util.Maps;

public class PersistUtil
{
    public static function serializeHashMap (output :IDataOutput, map :Map,
        serializeKey :Function = null, serializeValue :Function = null) :void
    {
        serializeKey = serializeKey == null ? serializeObject : serializeKey;
        serializeValue = serializeValue == null ? serializeObject : serializeValue;
        output.writeInt(map.size());
        map.forEach(function (key :Object, value :Object) :void {
            serializeKey(output, key);
            serializeValue(output, value);
        });
    }

    public static function serializeEnumIntMap (output :IDataOutput, map :Map) :void
    {
        serializeHashMap(output, map, serializeEnum, serializeInt);
    }

    public static function serializeEnumStringMap (output :IDataOutput, map :Map) :void
    {
        serializeHashMap(output, map, serializeEnum, serializeString);
    }

    public static function serializeSingleTypeMap (serializeFn :Function) :Function
    {
        return function (output :IDataOutput, map :Map) :void {
            serializeHashMap(output, map, serializeFn, serializeFn);
        }
    }

    public static function serializeObject (output :IDataOutput, value :Object) :void
    {
        output.writeObject(value);
    }

    public static function serializeEnum (output :IDataOutput, value :Enum) :void
    {
        output.writeUTF(value.name());
    }

    public static function serializeInt (output :IDataOutput, value :int) :void
    {
        output.writeInt(value);
    }

    public static function serializeString (output :IDataOutput, value :String) :void
    {
        output.writeUTF(value);
    }

    public static function deserializeHashMap (input :IDataInput, deserializeKey :Function = null,
        deserializeValue :Function = null) :Map
    {
        deserializeKey = deserializeKey == null ? deserializeObject : deserializeKey;
        deserializeValue = deserializeValue == null ? deserializeObject : deserializeValue;
        var map :Map = null;
        var size :int = input.readInt();
        for (var ii :int = 0; ii < size; ii++) {
            var key :Object = deserializeKey(input);
            var value :Object = deserializeValue(input);
            if (map == null) {
                map = Maps.newMapOf(ClassUtil.getClass(key));
            }
            map.put(key, value);
        }
        if (map == null) {
            map = Maps.newMapOf(Object);
        }
        return map;
    }

    public static function deserializeEnumIntMap (keyEnum :Class) :Function
    {
        return function (input :IDataInput) :Map {
            return deserializeHashMap(input, deserializeEnum(keyEnum), deserializeInt);
        };
    }

    public static function deserializeEnumStringMap (keyEnum :Class) :Function
    {
        return function (input :IDataInput) :Map {
            return deserializeHashMap(input, deserializeEnum(keyEnum), deserializeString);
        }
    }

    public static function deserializeSingleTypeMap (deserializeFn :Function) :Function
    {
        return function (input :IDataInput) :Map {
            return deserializeHashMap(input, deserializeFn, deserializeFn);
        }
    }

    public static function deserializeObject (input :IDataInput) :Object
    {
        return input.readObject();
    }

    public static function deserializeEnum (enum :Class) :Function
    {
        return function (input :IDataInput) :Enum {
            return Enum.valueOf(enum, input.readUTF());
        };
    }

    public static function deserializeInt (input :IDataInput) :int
    {
        return input.readInt();
    }

    public static function deserializeString (input :IDataInput) :String
    {
        return input.readUTF();
    }
}
}
