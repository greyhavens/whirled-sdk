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

import com.threerings.util.Maps;
import com.threerings.util.RandomUtil;
import com.threerings.util.StringUtil;
import com.threerings.util.sets.MapSet;

public class EffectSet extends MapSet
    implements SoundEffect
{
    public function EffectSet (name :String, playType :PlayType, initialEffects :Array = null)
    {
        super(Maps.newMapOf(String));
        _name = name;
        _playType = playType;

        if (initialEffects != null) {
            for each (var effect :String in initialEffects) {
                add(effect);
            }
        }
    }

    public function get name () :String
    {
        return _name;
    }

    // from SoundEffect
    public function get sound () :String
    {
        return RandomUtil.pickRandom(toArray()) as String;
    }

    // from SoundEffect
    public function get playType () :PlayType
    {
        return _playType;
    }

    // from Hashable
    public function hashCode () :int
    {
        return StringUtil.hashCode(_name);
    }

    // from Equalable
    public function equals (other :Object) :Boolean
    {
        return other is EffectSet && (other as EffectSet).name == _name;
    }

    // from HashSet
    override public function add (effect :Object) :Boolean
    {
        if (!(effect is String)) {
            return false;
        }

        return super.add(effect);
    }

    public function toString () :String
    {
        return "EffectSet [" + _name + ", " + _playType + "]";
    }

    protected var _name :String;
    protected var _playType :PlayType;
}
}
