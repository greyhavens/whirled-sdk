//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.data;

import com.threerings.presents.dobj.DSet.Entry;
import com.threerings.io.SimpleStreamableObject;

public class GameContentOwnership extends SimpleStreamableObject
    implements Entry, Comparable<GameContentOwnership>
{
    /** The game to which this content pertains. */
    public int gameId;

    /** The type of this content; see {@link GameData}. */
    public byte type;

    /** The identifier for this content. */
    public String ident;

    /** Used when unserializing. */
    public GameContentOwnership ()
    {
    }

    /**
     * Creates an ownership record for the specified game, type and ident.
     */
    public GameContentOwnership (int gameId, byte type, String ident)
    {
        this.gameId = gameId;
        this.type = type;
        this.ident = ident;
    }

    // from DSet.Entry
    public Comparable<?> getKey ()
    {
        return this;
    }

    // from Comparable
    public int compareTo (GameContentOwnership oo)
    {
        int rv = (oo.gameId - gameId);
        if (rv != 0) {
            return rv;
        }
        rv = (oo.type - type);
        if (rv != 0) {
            return rv;
        }
        return oo.ident.compareTo(ident);
    }

    @Override // from Object
    public boolean equals (Object other)
    {
        return (compareTo((GameContentOwnership)other) == 0);
    }
}
