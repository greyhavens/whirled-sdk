//
// $Id$
//
// Whirled contrib library - tools for developing whirled games
// Copyright (C) 2002-2008 Three Rings Design, Inc., All Rights Reserved
// http://www.whirled.com/code/contrib/asdocs
//
// This library is free software; you can redistribute it and/or modify it
// under the terms of the GNU Lesser General Public License as published
// by the Free Software Foundation; either version 2.1 of the License, or
// (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

package com.whirled.contrib.card {

import com.whirled.game.GameControl;
import com.whirled.game.NetSubControl;

/** Encapsulates the access and schema information for maintaining a fixed size array of integers
 *  on a whirled game server using NetSubControl. */
public class NetArray
{
    /** Creates a new net array.
     *  @param gameCtrl the Top-level game controller for the game using this array
     *  @param name the name of the server-side array
     *  @param length the number of entries in the array
     *  @param defaultValue the optional value to use when populating or proxying an array */
    public function NetArray (
        gameCtrl :GameControl, 
        name :String, 
        length :int,
        defaultValue :int = 0)
    {
        _gameCtrl = gameCtrl;
        _name = name;
        _length = length;
        _default = defaultValue;
    }

    /** Resets the contents of the array so that it has the given length and is filled with the 
     *  default value. This should normally be called early on in a game by the controlling 
     *  client. */
    public function reset () :void
    {
        var array: Array = new Array(_length);
        for (var i :int = 0; i < _length; ++i) {
            array[i] = _default;
        }
        net.set(_name, array);
    }

    /** Gets the integer at the given index. If the array has not yet been created, returns the 
     *  default value. This behavior is necessary since views of a game may need to be created
     *  prior to the completion of the round trip of the reset method call. */
    public function getAt (idx :int) :int
    {
        var array :Array = net.get(_name) as Array;
        if (array == null) {
            return _default;
        }
        return array[idx] as int;
    }

    /** Sets the integer at the given index. If the reset method has not been called or has not 
     *  completed its network round trip, an exception will be thrown (by NetSubControl). */
    public function setAt (idx :int, value :int) :void
    {
        net.setAt(_name, idx, value);
    }

    /** Adds an integer amount to the value at the given index. If the reset method has not been 
     *  called or has not completed its network round trip, an exception will be thrown (by 
     *  NetSubControl). */
    public function increment (idx :int, amount :int) :void
    {
        net.setAt(_name, idx, getAt(idx) + amount);
    }

    /** Access the fixed length of the array. */
    public function get length () :int
    {
        return _length;
    }

    /** Call the given function on each element of the array. If the resest method has not been
     *  called or has not completed its network round trip, does nothing. */
    public function forEach (fn :Function) :void
    {
        var array :Array = net.get(_name) as Array;
        if (array != null) {
            array.forEach(fn);
        }
    }

    /** Returns the index of the given value in the array, or -1 if not present. */
    public function indexOf (value :int) :int
    {
        var array :Array = net.get(_name) as Array;
        if (array == null) {
            return -1;
        }
        return array.indexOf(value);
    }

    protected function get net () :NetSubControl
    {
        return _gameCtrl.net;
    }

    protected var _gameCtrl :GameControl;
    protected var _name :String;
    protected var _length :int;
    protected var _default :int;
}

}
