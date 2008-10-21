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

package com.whirled.contrib.avrg.probe {

/**
 * Parameter type used when an array is expected. Parses a simple sequence of values in brackets
 * such as [1,2,3] or ["1", "2", "3"]. Commas within items like ["0,2"] will not work.
 */
public class ArrayParameter extends Parameter
{
    /**
     * Creates a new array parameter.
     * @param name the name of the parameter
     * @param type the type to use when parsing the values between commas
     * @param flags optional values passed to superclass
     */
    public function ArrayParameter (
        name :String, 
        type :Class, 
        flags :uint=0)
    {
        super(name, Array, flags);
        _underlying = type;
    }

    /** @inheritDoc */
    // from Parameter
    override public function get typeDisplay () :String
    {
        return "Array (" + _underlying + ")";
    }

    /** @inheritDoc */
    // from Parameter
    override public function parse (input :String) :Object
    {
        var temp :Parameter = new Parameter("", _underlying);
        var value :Array = [];
        var pos :int = 0;
        while (pos < input.length) {
            var comma :int = input.indexOf(",", pos);
            if (comma == -1) {
                comma = input.length;
            }
            value.push(temp.parse(input.slice(pos, comma)));
            pos = comma + 1;
        }
        return value;
    }

    protected var _underlying :Class;
}

}
