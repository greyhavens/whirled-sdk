//
// $Id$

package com.whirled.xml;

import com.threerings.ezgame.data.Parameter;

import com.whirled.data.GameData;
import com.whirled.data.ItemData;

/**
 * A file parameter for representing downloadable content packs on the test server.
 */
public abstract class ContentPackParameter extends Parameter
{
    /** URL to the content pack on the test server. */
    public String mediaURL = "";

    public abstract GameData toGameData ();

    @Override // documentation inherited
    public String getLabel ()
    {
        return "[content pack '" + ident + "']";
    }

    @Override // documentation inherited
    public Object getDefaultValue ()
    {
        return new byte[0];
    }
}
