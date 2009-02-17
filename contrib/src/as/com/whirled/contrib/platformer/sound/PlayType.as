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

package com.whirled.contrib.platformer.sound {

import com.threerings.util.Enum;

public final class PlayType extends Enum
{
    // If a new play of this SoundEffect is requested, it will not be started if there is one
    // already playing
    public static const CONTINUOUS :PlayType = new PlayType("CONTINUOUS");

    // If a new play of this SoundEffect is requested, the currently playing effect will be stopped
    // and a new instance started.
    public static const RESTARTING :PlayType = new PlayType("RESTARTING");

    // Newly requested plays of this SoundEffect will overlap any previously playing instances.
    public static const OVERLAPPING :PlayType = new PlayType("OVERLAPPING");

    finishedEnumerating(PlayType);


    public static function values () :Array
    {
        return Enum.values(PlayType);
    }

    public static function valueOf (name :String) :PlayType
    {
        return Enum.valueOf(PlayType, name) as PlayType;
    }

    // @private
    public function PlayType (name :String)
    {
        super(name);
    }
}
}
