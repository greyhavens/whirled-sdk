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
 * Parameter type to use when a <code>Function</code> is expected. This is an automated type that
 * has no parsing. It is treated specially by the framework that uses it.
 */
public class CallbackParameter extends Parameter
{
    /**
     * Creates a new callback parameter.
     * @param name the name of the parameter
     * @param flags optional values passed to superclass
     */
    public function CallbackParameter (name :String, flags :uint=0)
    {
        super(name, Function, flags);
    }

    /** @inheritDoc */
    // from Parameter
    override public function get typeDisplay () :String
    {
        return "Function";
    }

    /** @inheritDoc */
    // from Parameter
    override public function parse (input :String) :Object
    {
        throw new Error("Callbacks not parsed");
    }
}

}
