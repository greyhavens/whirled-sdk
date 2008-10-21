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
 * Holds everything needed to generate the parameters for and call a function.
 */
public class FunctionSpec
{
    /**
     * Creates a new function spec.
     * @param name the name of the function
     * @param func the function
     * @param parameters an array of <code>Parameter<code> objects that represent the function's
     * actual parameters
     * @see com.whirled.contrib.avrg.probe.Parameter
     */
    public function FunctionSpec (
        name :String, 
        func :Function,
        parameters :Array = null)
    {
        _func = func;
        _name = name;
        if (parameters == null) {
            _parameters = [];
        } else {
            _parameters = parameters.slice();
        }
    }

    /**
     * The name of the function.
     */
    public function get name () :String
    {
        return _name;
    }

    /**
     * The action script callable object.
     */
    public function get func () :Function
    {
        return _func;
    }

    /**
     * The array of <code>Parameters</code> to the function.
     * @see com.whirled.contrib.avrg.probe.Parameter
     */
    public function get parameters () :Array
    {
        return _parameters.slice();
    }

    protected var _func :Function;
    protected var _name :String;
    protected var _parameters :Array;
}

}
