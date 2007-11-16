//
// $Id$

package com.whirled.data {

import com.threerings.ezgame.data.GameDefinition;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.ObjectInputStream;
import com.threerings.io.TypedArray;

/**
 * Hardcodes the media path for use when testing.
 */
public class WhirledGameDefinition extends GameDefinition
{
    /** Definitions of content packs on the test server. */
    public var packs :TypedArray;

    // from interface Streamable
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        packs = (ins.readObject() as TypedArray);
    }

    // from interface Streamable
    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeObject(packs);
    }

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

    // from GameDefinition
    override public function fuckingCompiler () :void
    {
        super.fuckingCompiler(); // :)
        var c :Class;
        // Parameter derivations
        c = ItemPackParameter;
        c = LevelPackParameter;
    }
}
}
