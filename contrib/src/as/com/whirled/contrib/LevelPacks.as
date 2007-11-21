// $Id$

package com.threerings.underwhirleddrift.util {

import com.threerings.util.HashMap;

public class LevelPacks 
{
    /** 
     * Call init after the WhirledGameControl is connected and the level packs are available.
     */
    public static function init (levelPacks :Array) :void
    {
        for each (var levelPack :Object in levelPacks) {
            _levelPacks.put(levelPack.ident, new LevelPack(levelPack.ident, levelPack.name, 
                                                           levelPack.mediaURL, levelPack.premium));
        }
    }

    /**
     * Returns true if the given ident is a recognized level pack.
     */
    public static function isLevelPack (ident :String) :Boolean
    {
        return _levelPacks.containsKey(ident);
    }

    /**
     * Returns an array of all of the recognized level pack idents as Strings.
     */
    public static function getAvailableIdents () :Array
    {
        return _levelPacks.keys();
    }

    /**
     * Returns the media URL for the given ident, or null if that ident is not recognized.
     */
    public static function getMediaURL (ident :String) :String
    {
        var pack :LevelPack = _levelPacks.get(ident) as LevelPack;
        return pack != null ? pack.mediaURL : null;
    }

    /**
     * Returns the typed LevelPack object for the given level pack ident, or null if the ident
     * is not recognized.
     */
    public static function getLevelPack (ident :String) :LevelPack
    {
        return _levelPacks.get(ident);
    }

    /**
     * Returns the an array of the typed LevelPack objects.
     */
    public static function getLevelPacks () :Array
    {
        return _levelPacks.values();
    }

    protected static var _levelPacks :HashMap = new HashMap();
}
}
