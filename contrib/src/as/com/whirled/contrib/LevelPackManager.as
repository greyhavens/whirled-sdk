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

package com.whirled.contrib {

import com.threerings.util.Map;
import com.threerings.util.Maps;

public class LevelPackManager
{
    /**
     * Call init after the WhirledGameControl is connected and the level packs are available.
     */
    public function init (levelPacks :Array) :void
    {
        _levelPacks.clear();
        for each (var levelPack :Object in levelPacks) {
            _levelPacks.put(levelPack.ident, new LevelPack(levelPack.ident, levelPack.name,
                                                           levelPack.mediaURL, levelPack.premium));
        }
    }

    /**
     * Returns true if the given ident is a recognized level pack.
     */
    public function isLevelPack (ident :String) :Boolean
    {
        return _levelPacks.containsKey(ident);
    }

    /**
     * Returns an array of all of the recognized level pack idents as Strings.
     */
    public function getAvailableIdents () :Array
    {
        return _levelPacks.keys();
    }

    /**
     * Returns the media URL for the given ident, or null if that ident is not recognized.
     */
    public function getMediaURL (ident :String) :String
    {
        var pack :LevelPack = _levelPacks.get(ident) as LevelPack;
        return pack != null ? pack.mediaURL : null;
    }

    /**
     * Returns the typed LevelPack object for the given level pack ident, or null if the ident
     * is not recognized.
     */
    public function getLevelPack (ident :String) :LevelPack
    {
        return _levelPacks.get(ident);
    }

    /**
     * Returns the an array of the typed LevelPack objects.
     */
    public function getLevelPacks () :Array
    {
        return _levelPacks.values();
    }

    protected var _levelPacks :Map = Maps.newMapOf(String);
}
}
