//
// $Id$

package com.whirled.data;

import com.whirled.data.GameData;
import com.whirled.data.LevelData;

/**
 * A file parameter for representing downloadable level packs on the test server.
 */
public class LevelPackParameter extends ContentPackParameter
{
    /** Is the level pack premium? */
    public boolean premium;
    
    public GameData toGameData ()
    {
        LevelData data = new LevelData();
        data.ident = this.ident;
        data.name = this.name;
        data.mediaURL = this.mediaURL;
        data.premium = premium;
        return data;
    }
}
