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

import com.threerings.util.StringUtil;

/**
 * Represents a named, typed parameter to an action script function. Basic types are handled:
 * String, int, Number, Boolean. Other types are handled by subclasses.
 */
public class Parameter
{
    /** Flag value for parameters that are optional. */
    public static const OPTIONAL :int = 1;

    /** Flag value for parameters that may take null. */
    public static const NULLABLE :int = 2;

    /**
     * Tests if a character is a digit.
     */
    public static function isDigit (char :String) :Boolean
    {
        return "0123456789".indexOf(char) >= 0;
    }

    /**
     * Tests if a character is alphabetic.
     */
    public static function isAlpha (char :String) :Boolean
    {
        return "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_".indexOf(char) >= 0;
    }

    /**
     * Tests if a character is whitespace.
     */
    public static function isWhitespace (char :String) :Boolean
    {
        return StringUtil.isWhitespace(char);
    }

    /**
     * Trims a string's leading and trailing whitespace.
     */
    public static function trim (str :String) :String
    {
        return StringUtil.trim(str);
    }

    /**
     * Creates a new parameter.
     * @param name the name of the parameter
     * @param type the type of the parameter
     * @param flags one or more flag values or'ed together
     * @see #NULLABLE
     * @see #OPTIONAL
     */
    public function Parameter (
        name :String, 
        type :Class, 
        flags :uint=0)
    {
        _name = name;
        _type = type;
        _flags = flags;
    }

    /**
     * The name of the parameter.
     */
    public function get name () :String
    {
        return _name;
    }

    /**
     * The type of the parameter.
     */
    public function get type () :Class
    {
        return _type;
    }

    /**
     * A concise string representing the type of the parameter for user interfaces.
     */
    public function get typeDisplay () :String
    {
        if (_type == String) {
            return "String";

        } else if (_type == int) {
            return "int";

        } else if (_type == Boolean) {
            return "Bool";

        } else if (_type == Number) {
            return "Number";
        }

        return "" + _type;
    }

    /**
     * Translates a string to an object of this parameter's type.
     * @throws Error if the string could not be translated
     */
    public function parse (input :String) :Object
    {
        if (_type == String) {
            return input;

        } else if (_type == int) {
            return StringUtil.parseInteger(input);

        } else if (_type == Boolean) {
            input = input.toLowerCase();
            if (input == "t" || input == "true") {
                return true;
            } else if (input == "f" || input == "false") {
                return false;
            } else {
                throw new Error(input + " is not a Boolean");
            }

        } else if (_type == Number) {
            return StringUtil.parseNumber(input);
        }

        throw new Error("Parsing for parameter type " + type + 
            " not implemented");
    }

    /**
     * Whether this parameter may be omitted when calling the function.
     */
    public function get optional () :Boolean
    {
        return (_flags & OPTIONAL) != 0;
    }

    /**
     * Whether null may be passed for this parameter's value.
     */
    public function get nullable () :Boolean
    {
        return (_flags & NULLABLE) != 0;
    }

    protected var _name :String;
    protected var _type :Class;
    protected var _flags :uint;
}

}
