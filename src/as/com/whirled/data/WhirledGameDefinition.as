//
// $Id$

package com.whirled.data {

import com.threerings.ezgame.data.GameDefinition;

/**
 * Hardcodes the media path for use when testing.
 */
public class WhirledGameDefinition extends GameDefinition
{
    public function WhirledGameDefinition ()
    {
        // nada
    }

    // from GameDefinition
    override public function getMediaPath (gameId :int) :String
    {
        // The clients are started with the URL as 'localhost', but to fully test
        // games with the security boundary we access the game swf from 127.0.0.1.
        // It's the same thing, but the flashplayer will treat them differently.
        return "http://127.0.0.1:8080/" + ident + ".swf";
    }
}
}
