//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.data;

import com.threerings.io.SimpleStreamableObject;
import com.threerings.presents.dobj.DSet;

/**
 * Notes that a player owns a particular piece of {@link GameData}.
 */
public class Ownership extends SimpleStreamableObject
    implements DSet.Entry, Comparable
{
    /** The type of {@link GameData} in question. */
    public byte type;

    /** The identifier of the {@link GameData} in question. */
    public String ident;

    /** The player that owns the {@link GameData}. */
    public int playerId;

    // from interface DSet.Entry
    public Comparable getKey ()
    {
        return this;
    }

    // from interface Comparable
    public int compareTo (Object other)
    {
        Ownership oo = (Ownership)other;
        int rv = (oo.type - type);
        if (rv != 0) {
            return rv;
        }
        rv = oo.ident.compareTo(ident);
        if (rv != 0) {
            return rv;
        }
        return oo.playerId - playerId;
    }

    // @Override // from Object
    public boolean equals (Object other)
    {
        return (compareTo(other) == 0);
    }
}
