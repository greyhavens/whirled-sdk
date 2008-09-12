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

package com.whirled.contrib {

public interface ManagedTimer
{
    function get currentCount () :int;
    function get delay () :Number;
    function set delay (val :Number) :void;
    function get repeatCount () :int;
    //function set repeatCount (val :int) :void // Thane doesn't support this right now
    function get running () :Boolean;

    function reset () :void;
    function start () :void;
    function stop () :void;

    /**
     *  Removes the ManagedTimer from its TimerManager.
     *  It is an error to call any function on a timer that has been canceled.
     */
    function cancel () :void;
}

}
