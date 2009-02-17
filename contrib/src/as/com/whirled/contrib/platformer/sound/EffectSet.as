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

import com.threerings.util.HashSet;
import com.threerings.util.RandomUtil;

public class EffectSet extends HashSet
{
    public function EffectSet (name :String, initialEffects :Array = null)
    {
        _name = name;

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

    // from HashSet
    override public function add (effect :Object) :Boolean
    {
        if (!(effect is String)) {
            return false;
        }

        return super.add(effect);
    }

    public function getRandomEntry () :String
    {
        return RandomUtil.pickRandom(toArray()) as String;
    }

    protected var _name :String;
}
}
