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

package com.whirled.contrib.persist {

import com.whirled.game.PlayerSubControl;

public /*abstract*/ class PropertyPrototype
{
    public function PropertyPrototype (name :String, playerId :int = 0)
    {
        _name = name;
        _playerId = playerId;
    }

    public function get name () :String
    {
        return _name;
    }

    public /*abstract*/ function get type () :PropertyType
    {
        throw new Error("get type() in PropertyPrototype is abstract!");
    }

    public function get playerId () :int
    {
        return _playerId;
    }

    protected var _name :String;
    protected var _playerId :int = PlayerSubControl.CURRENT_USER;
}
}
