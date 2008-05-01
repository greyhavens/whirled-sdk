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

package com.whirled.contrib.card.graphics {

/** Represents the state of a card sprite. */
public class CardState
{
    /** Create a card state. A state is the color and opacity of a rectangular sprite overlaying 
     *  the card. */
    public function CardState (color :uint, alpha :Number, name :String=null)
    {
        _color = color;
        _alpha = alpha;
        _name = name;
    }

    public function get alpha () :Number
    {
        return _alpha;
    }

    public function get color () :uint
    {
        return _color;
    }

    public function get name () :String
    {
        return _name;
    }

    /** @inheritDoc */
    // from Object
    public function toString () :String
    {
        if (_name != null) {
            return _name;
        }
        return "Color: " + _color.toString(16) + ", Alpha: " + _alpha;
    }

    private var _color :uint;
    private var _alpha :Number;
    private var _name :String;
}

}
