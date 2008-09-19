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

package com.whirled.contrib.card {

/** Debugging utilities. */
public class Debug
{
    /** Function for printing debug information within the card packages. The function accepts a 
     *  string and appends a line break automatically:
     *
     *      function debug (str :String) :void
     *
     *  Initially, the value of the function is set to a default function that just calls trace. 
     *  The function can be changed by client code at any time, but must never be set to null. */
    public static var debug :Function = defaultDebugPrint;

    /** Basic flash native printing for use prior to overriding. */
    protected static function defaultDebugPrint (str :String) :void
    {
        trace(str + "\n");
    }
}

}
