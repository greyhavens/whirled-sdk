//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.SimpleStreamableObject;
import com.threerings.util.Comparable;

import com.threerings.presents.dobj.DSet_Entry;

/**
 * Notes that a player owns a particular piece of {@link GameData}.
 */
public class Ownership extends SimpleStreamableObject
    implements DSet_Entry, Comparable
{
    /** The type of {@link GameData} in question. */
    public var type :int;

    /** The identifier of the {@link GameData} in question. */
    public var ident :String;

    /** The player that owns the {@link GameData}. */
    public var playerId :int;

    public function Ownership ()
    {
        // nada
    }

    // from interface Comparable
    public function compareTo (other :Object) :int
    {
        var oo :Ownership = (other as Ownership);
        var rv :int = (oo.type - type);
        if (rv != 0) {
            return rv;
        }
        rv = oo.ident.localeCompare(ident);
        if (rv != 0) {
            return rv;
        }
        return (oo.playerId - playerId);
    }

    // from Object
    public function equals (other :Object) :Boolean
    {
        return (compareTo(other) == 0);
    }

    // from interface DSet_Entry
    public function getKey () :Object
    {
        return this;
    }

    // from interface Streamable
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        type = ins.readByte();
        ident = (ins.readField(String) as String);
        playerId = ins.readInt();
    }

    // from interface Streamable
    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeByte(type);
        out.writeField(ident);
        out.writeInt(playerId);
    }
}
}
