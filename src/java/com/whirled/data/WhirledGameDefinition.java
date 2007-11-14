//
// $Id$

package com.whirled.data;

import java.io.File;
import java.util.ArrayList;

import com.threerings.ezgame.data.GameDefinition;
import com.threerings.ezgame.data.Parameter;

/**
 * Customizes the game definition, providing the path to the game code and media when running in
 * the test server.
 */
public class WhirledGameDefinition extends GameDefinition
{
    /** Definitions of content packs on the test server. */
    public Parameter[] packs;

    @Override // from GameDefinition
    public String getMediaPath (int gameId)
    {
        return "dist" + File.separator + ident + ".jar";
    }

    /** Called when parsing pack definitions from XML. */
    public void setPacks (ArrayList<Parameter> list)
    {
        packs = list.toArray(new Parameter[list.size()]);
    }

}
