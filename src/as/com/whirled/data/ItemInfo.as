//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.SimpleStreamableObject;

import com.threerings.presents.dobj.DSet_Entry;

/**
 * Contains information on an item pack available to this game.
 */
public class ItemInfo extends SimpleStreamableObject
    implements DSet_Entry
{
    /** A unique identifier for this pack. */
    public var ident :String;

    /** A human readable name for this pack. */
    public var name :String;

    /** The URL from which this pack's media can be downloaded. */
    public var mediaURL :String;

    // from interface DSet_Entry
    public function getKey () :Object
    {
        return ident;
    }

    // from SimpleStreamableObject
    override public function readObject (ins :ObjectInputStream) :void
    {
        ident = (ins.readField(String) as String);
        name = (ins.readField(String) as String);
        mediaURL = (ins.readField(String) as String);
    }

    // from SimpleStreamableObject
    override public function writeObject (out :ObjectOutputStream) :void
    {
        out.writeField(ident);
        out.writeField(name);
        out.writeField(mediaURL);
    }
}
}
