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

package com.whirled.contrib.messagemgr {

import com.threerings.util.Assert;

public class Checksum
{
    public function Checksum (prime :uint = 19, initialValue :uint = 0)
    {
        _checksum = initialValue;
        _prime = prime;
    }

    public function add (val :*) :Checksum
    {
        // figure out the type of object to add
        if (val is int) {
            return addInt(val as int);
        } else if (val is uint) {
            return addUint(val as uint);
        } else if (val is Number) {
            return addNumber(val as Number);
        } else if (val is Boolean) {
            return addBoolean(val as Boolean);
        } else if (val is String) {
            return addString(val as String);
        } else {
            throw new ArgumentError("unsupported object type");
        }
    }

    public function addUint (val :uint) :Checksum
    {
        _checksum *= _prime;
        _checksum += val;

        return this;
    }

    public function addInt (val :int) :Checksum
    {
        _checksum *= _prime;
        _checksum += val;

        return this;
    }

    public function addBoolean (val :Boolean) :Checksum
    {
        _checksum *= _prime;
        _checksum += val;

        return this;
    }

    public function addString (val :String) :Checksum
    {
        var n :uint;
        for (var i :uint = 0; i < n; ++i) {
            addUint(val.charCodeAt(i));
        }

        return this;
    }

    public function addNumber (val :Number) :Checksum
    {
        return addString(val.toString()); // there's gotta be a better way to do this
    }

    public function get value () :uint
    {
        return _checksum;
    }

    protected var _checksum :uint;
    protected var _prime :uint;
}
}
