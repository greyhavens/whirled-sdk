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

import com.whirled.game.GameControl;

public class TrophyProperty extends PersistentProperty
{
    public function TrophyProperty (name :String, gameCtrl :GameControl)
    {
        super(name);

        _gameCtrl = gameCtrl;
    }

    override public function get value () :Object
    {
        return hasTrophy();
    }

    public function awardTrophy () :void
    {
        if (hasTrophy()) {
            throw new Error("This player already holds this trophy [" + _name + "]");
        }

        _gameCtrl.player.awardTrophy(_name);
    }

    public function hasTrophy () :Boolean
    {
        return _gameCtrl.player.holdsTrophy(_name);
    }

    protected var _gameCtrl :GameControl;
}
}
