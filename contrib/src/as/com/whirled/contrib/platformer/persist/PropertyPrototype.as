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

package com.whirled.contrib.platformer.persist {

import com.whirled.game.PlayerSubControl;

public class PropertyPrototype 
{
    public function PropertyPrototype (name :String, type :PropertyType, 
        defaultValue :Object = null, playerId :int = PlayerSubControl.CURRENT_USER)
    {
        _name = name;
        _type = type;
        _defaultValue = defaultValue;
        _playerId = playerId;
    }

    public function get name () :String
    {
        return _name;
    }

    public function get type () :PropertyType
    {
        return _type;
    }

    public function get defaultValue () :Object
    {
        return _defaultValue;
    }

    public function get playerId () :int
    {
        return _playerId;
    }

    protected var _name :String;
    protected var _type :PropertyType;
    protected var _defaultValue :Object;
    protected var _playerId :int;
}
}
