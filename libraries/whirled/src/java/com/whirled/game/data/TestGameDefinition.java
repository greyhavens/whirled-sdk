//
// $Id$

package com.whirled.game.data;

import java.io.File;
import java.util.ArrayList;

import com.threerings.parlor.data.Parameter;

/**
 * Customizes the game definition, providing the path to the game code and media when running in
 * the test server.
 */
public class TestGameDefinition extends GameDefinition
{
    /** Definitions of content packs on the test server. */
    public Parameter[] packs;

    /** True if game has server side code. */
    public transient boolean hasServer;

    @Override // from GameDefinition
    public String getMediaPath (int gameId)
    {
        return "dist" + File.separator + ident + ".jar";
    }

    @Override
    public String getServerMediaPath (int gameId)
    {
        return hasServer ? "http://localhost:8080/" + ident + ".abc" : null;
    }

    /** Called when parsing pack definitions from XML. */
    public void setPacks (ArrayList<Parameter> list)
    {
        packs = list.toArray(new Parameter[list.size()]);
    }

}
