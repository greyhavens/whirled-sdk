//
// $Id$

package com.whirled.xml;

import com.whirled.data.GameData;
import com.whirled.data.ItemData;

/**
 * A file parameter for representing downloadable content packs on the test server.
 */
public class ItemPackParameter extends ContentPackParameter
{
    public GameData toGameData ()
    {
        ItemData data = new ItemData();
        data.ident = this.ident;
        data.name = this.name;
        data.mediaURL = this.mediaURL;
        return data;
    }
}
