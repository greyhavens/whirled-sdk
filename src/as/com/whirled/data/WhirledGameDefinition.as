//
// $Id$

package com.whirled.data {

import com.threerings.ezgame.data.GameDefinition;

/**
 * Hardcodes the media path for use when testing.
 */
public class WhirledGameDefinition extends GameDefinition
{
    // from GameDefinition
    override public function getMediaPath (gameId :int) :String
    {
        return "http://localhost:8080/" + ident + ".swf";
    }
}
}
