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

package com.whirled.contrib.sound {

import com.threerings.util.StringUtil;

public class SimpleSoundEffect
    implements SoundEffect
{
    public function SimpleSoundEffect (sound :String, playType :PlayType)
    {
        _sound = sound;
        _playType = playType;
    }

    // from SoundEffect
    public function get sound () :String
    {
        return _sound;
    }

    // from SoundEffect
    public function get playType () :PlayType
    {
        return _playType;
    }

    // from Hashable
    public function hashCode () :int
    {
        return StringUtil.hashCode(_sound) * _playType.hashCode();
    }

    // from Equalable
    public function equals (o :Object) :Boolean
    {
        if (!(o is SimpleSoundEffect)) {
            return false;
        }

        var other :SimpleSoundEffect = o as SimpleSoundEffect;
        return other.sound == _sound && other.playType == _playType;
    }

    public function toString () :String
    {
        return "SimpleSoundEffect [" + sound + ", " + playType + "]";
    }

    protected var _sound :String;
    protected var _playType :PlayType;
}
}
