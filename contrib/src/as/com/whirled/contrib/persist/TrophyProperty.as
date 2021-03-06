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

import com.whirled.game.GameControl;
import com.whirled.game.PlayerSubControl;

public class TrophyProperty
    implements PersistentProperty
{
    public function TrophyProperty (name :String, gameCtrl :GameControl,
        playerId :int = 0 /*PlayerSubControl.CURRENT_USER*/)
    {
        _name = name;
        _gameCtrl = gameCtrl;
        _playerId = playerId;
    }

    // from PersistentProperty
    public function get name () :String
    {
        return _name;
    }

    public function get playerId () :int
    {
        return _playerId;
    }

    public function awardTrophy () :Boolean
    {
        if (hasTrophy()) {
            trace("This player already holds this trophy [" + _name + "]");
            return false;
        }

        return _awardedThisSession = _gameCtrl.player.awardTrophy(_name, _playerId);
    }

    public function hasTrophy () :Boolean
    {
        // The game API does not return true from holdsTrophy() immediately after awardTrophy()
        // is called, so we're caching trophies awarded this session.
        return _awardedThisSession || _gameCtrl.player.holdsTrophy(_name, _playerId);
    }

    protected var _gameCtrl :GameControl;
    protected var _name :String;
    protected var _playerId :int;
    protected var _awardedThisSession :Boolean = false;
}
}
