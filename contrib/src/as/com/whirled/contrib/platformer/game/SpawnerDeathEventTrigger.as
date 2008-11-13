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

package com.whirled.contrib.platformer.game {

import com.whirled.contrib.platformer.piece.Dynamic;
import com.whirled.contrib.platformer.piece.Spawner;

public class SpawnerDeathEventTrigger extends DeathEventTrigger
{
    public function SpawnerDeathEventTrigger (gctrl :GameController, xml :XML)
    {
        super(gctrl, xml);
        _id = xml.@id;
        _ignoreSpawns = xml.@ignoreSpawns == "true";
    }

    override protected function testTriggered () :Boolean
    {
        if (_ids != null) {
            return super.testTriggered();
        }
        var d :Dynamic = _gctrl.getBoard().getDynamic(_id);
        if (d == null) {
            return false;
        } else if (!(d is Spawner)) {
            return true;
        }
        var s :Spawner = d as Spawner;
        if (s.destructable && s.health <= 0) {
            if (_ignoreSpawns) {
                return true;
            }
            _ids = s.spawns;
        } else if (!s.destructable && s.spawnCount == s.totalSpawns) {
            _ids = s.spawns;
        }
        return false;
    }

    protected var _id :int;
    protected var _ignoreSpawns :Boolean;
}
}
