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

import flash.utils.ByteArray

import com.threerings.util.Log;

public /*abstract*/ class TypedArrayCookieProperty extends CookieProperty
{
    public function TypedArrayCookieProperty (manager :CookieManager, name :String = null,
        defaultValue :Array = null)
    {
        super(manager, name);

        if (defaultValue != null) {
            if (!(defaultValue is Array)) {
                throw new ArgumentError("The defaultValue of a TypedArrayCookieProperty must be " +
                    "an array");
            }
            requireValidValue(defaultValue);
            _array = defaultValue.concat();
        }
    }

    override public function set value (value :Object) :void
    {
        if (!(value is Array)) {
            throw new ArgumentError("TypedArrayCookieProperty value must be an Array");
        }
        requireValidValue(value);
        _array = value as Array;
        _manager.cookiePropertyUpdated(this);
    }

    override public function get value () :Object
    {
        return _array.concat();
    }

    public function get length () :int
    {
        return _array.length;
    }

    public function set length (value :int) :void
    {
        _array.length = value;
        _manager.cookiePropertyUpdated(this);
    }

    public function pop () :Object
    {
        var value :Object = _array.pop()
        _manager.cookiePropertyUpdated(this);
        return value;
    }

    public function push (obj :Object) :void
    {
        requireValidValue(obj);
        _array.push(obj);
        _manager.cookiePropertyUpdated(this);
    }

    public function shift () :Object
    {
        var value :Object = _array.shift();
        _manager.cookiePropertyUpdated(this);
        return value;
    }

    public function unshift (obj :Object) :void
    {
        requireValidValue(obj);
        _array.unshift(obj);
        _manager.cookiePropertyUpdated(this);
    }

    public function getAt (idx :int) :Object
    {
        return _array[idx];
    }

    public function removeAt (idx :int) :Object
    {
        var value :Object = _array[idx];
        _array = _array.splice(idx, 1);
        _manager.cookiePropertyUpdated(this);
        return value;
    }

    public function remove (obj :Object) :Object
    {
        var idx :int = indexOf(obj);
        if (idx < 0) {
            return null;
        }
        return removeAt(idx);
    }

    public function indexOf (obj :Object) :int
    {
        return _array.indexOf(obj);
    }

    public function putAt (idx :int, obj :Object) :void
    {
        requireValidValue(obj);
        _array[idx] = obj;
        _manager.cookiePropertyUpdated(this);
    }

    override public function serialize (bytes :ByteArray) :void
    {
        bytes.writeUTF(_name);
        serializeValue(bytes, _array);
    }

    override public function deserialize (bytes :ByteArray) :void
    {
        _name = bytes.readUTF();
        _array = deserializeValue(bytes) as Array;
    }

    protected /*abstract*/ function get type () :Class
    {
        throw new Error("get type() in TypedArrayCookieProperty is abstract!");
    }

    protected /*abstract*/ function serializeField (bytes :ByteArray, value :Object) :void
    {
        throw new Error("serializeField in TypedArrayCookieProeprty is abstract!");
    }

    protected /*abstract*/ function deserializeField (bytes :ByteArray) :Object
    {
        throw new Error("deserializeField in TypedArrayCookieProeprty is abstract!");
    }

    protected function serializeValue (bytes :ByteArray, value :Object) :void
    {
        if (value is Array) {
            var array :Array = value as Array;
            bytes.writeByte(ARRAY_MARKER);
            bytes.writeInt(array.length);
            for each (var member :Object in array) {
                serializeValue(bytes, member);
            }

        } else {
            bytes.writeByte(VALUE_MARKER);
            serializeField(bytes, value);
        }
    }

    protected function deserializeValue (bytes :ByteArray) :Object
    {
        var marker :int = bytes.readByte();
        var value :Object = null;
        if (marker == ARRAY_MARKER) {
            value = [];
            var length :int = bytes.readInt();
            for (var ii :int = 0; ii < length; ii++){
                value[ii] = deserializeValue(bytes);
            }

        } else if (marker == VALUE_MARKER) {
            value = deserializeField(bytes);

        } else {
            log.warning("Unknown marker found", "marker", marker);
        }
        return value;
    }

    protected function valueCheck (value :Object) :Boolean
    {
        if (!(value is Array)) {
            return value is type;
        }

        var array :Array = value as Array;
        for (var ii :int = 0; ii < array.length; ii++) {
            if (!valueCheck(array[ii])) {
                return false;
            }
        }
        return true;
    }

    protected function requireValidValue (value :Object) :void
    {
        if (!valueCheck(value)) {
            throw new ArgumentError(
                "This TypedArrayCookieProperty only accepts " + type + "values");
        }
    }

    protected var _array :Array = [];

    protected static const ARRAY_MARKER :int = 0;
    protected static const VALUE_MARKER :int = 1;

    private static const log :Log = Log.getLog(TypedArrayCookieProperty);
}
}
