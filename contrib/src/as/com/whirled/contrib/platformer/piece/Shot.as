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

package com.whirled.contrib.platformer.piece {

import com.whirled.contrib.sound.SoundEffect;

import com.whirled.contrib.platformer.game.Collision;
import com.whirled.contrib.platformer.util.Effect;

/**
 * A base class for shots as dynamic objects.
 */
public class Shot extends Dynamic
{
    public var damage :Number = 0;
    public var ttl :Number = 0;
    public var hit :Collision = null;
    public var miss :Collision = null;
    public var bigHit :Boolean = false;
    public var hitEffect :Effect;
    public var missEffect :Effect;
    public var airEffect :Effect;
    public var force :Number = 0;
    public var source :int = 0;
    public var rotateHit :Boolean = false;
    public var fireSoundEffect :SoundEffect;
    public var genericHitSoundEffect :SoundEffect;
    public var genericMissSoundEffect :SoundEffect;

    override public function shouldSpawn () :Boolean
    {
        return false;
    }

    override public function useCache () :Boolean
    {
        return false;
    }
}
}
