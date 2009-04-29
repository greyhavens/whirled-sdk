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

public class LevelPacks
{
    /**
     * Call init after the WhirledGameControl is connected and the level packs are available.
     */
    public static function init (levelPacks :Array) :void
    {
        _mgr.init(levelPacks);
    }

    /**
     * Returns true if the given ident is a recognized level pack.
     */
    public static function isLevelPack (ident :String) :Boolean
    {
        return _mgr.isLevelPack(ident);
    }

    /**
     * Returns an array of all of the recognized level pack idents as Strings.
     */
    public static function getAvailableIdents () :Array
    {
        return _mgr.getAvailableIdents();
    }

    /**
     * Returns the media URL for the given ident, or null if that ident is not recognized.
     */
    public static function getMediaURL (ident :String) :String
    {
        return _mgr.getMediaURL(ident);
    }

    /**
     * Returns the typed LevelPack object for the given level pack ident, or null if the ident
     * is not recognized.
     */
    public static function getLevelPack (ident :String) :LevelPack
    {
        return _mgr.getLevelPack(ident);
    }

    /**
     * Returns the an array of the typed LevelPack objects.
     */
    public static function getLevelPacks () :Array
    {
        return _mgr.getLevelPacks();
    }

    /**
     * Returns the concrete LevelPackManager used by all of the static functions in this class.
     */
    public static function getGlobalManager () :LevelPackManager
    {
        return _mgr;
    }

    protected static var _mgr :LevelPackManager = new LevelPackManager();
}
}
