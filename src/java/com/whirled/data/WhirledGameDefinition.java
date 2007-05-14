//
// $Id$

package com.whirled.data;

import java.io.File;

import com.threerings.ezgame.data.GameDefinition;

/**
 * Customizes the game definition, providing the path to the game code and media when running in
 * the test server.
 */
public class WhirledGameDefinition extends GameDefinition
{
    @Override // from GameDefinition
    public String getMediaPath (int gameId)
    {
        return "dist" + File.separator + ident + ".jar";
    }
}
