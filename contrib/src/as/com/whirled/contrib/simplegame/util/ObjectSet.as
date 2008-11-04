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

package com.whirled.contrib.simplegame.util {

import com.threerings.util.Set;

import flash.utils.Dictionary;

public class ObjectSet
    implements Set
{
    public function add (o :Object) :Boolean
    {
        if (this.contains(o)) {
            return false;
        } else {
            _dict[o] = null;
            ++_size;
            return true;
        }
    }

    public function remove (o :Object) :Boolean
    {
        if (this.contains(o)) {
            delete _dict[o];
            --_size;
            return true;
        } else {
            return false;
        }
    }

    public function clear () :void
    {
        for (var key :* in _dict) {
            delete _dict[key];
        }

        _size = 0;
    }

    public function contains (o :Object) :Boolean
    {
        return (undefined !== _dict[o]);
    }

    public function size () :int
    {
        return _size;
    }

    public function isEmpty () :Boolean
    {
        return (0 == _size);
    }

    public function toArray () :Array
    {
        var arr :Array = new Array();

        for (var key :* in _dict) {
            arr.push(key);
        }

        return arr;
    }

    public function forEach (callback :Function) :void
    {
        for (var key :* in _dict) {
            callback(key);
        }
    }

    protected var _dict :Dictionary = new Dictionary();
    protected var _size :int = 0;
}

}
