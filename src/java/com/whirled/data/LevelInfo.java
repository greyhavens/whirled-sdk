//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.data;

import com.threerings.io.SimpleStreamableObject;

import com.threerings.presents.dobj.DSet;

/**
 * Contains information on a level pack available to this game.
 */
public class LevelInfo extends SimpleStreamableObject
    implements DSet.Entry
{
    /** A unique identifier for this pack. */
    public String ident;

    /** A human readable name for this pack. */
    public String name;

    /** The URL from which this pack's media can be downloaded. */
    public String mediaURL;

    /** Whether or not this pack is premium or free. */
    public boolean premium;

    // from interface DSet.Entry
    public Comparable getKey ()
    {
        return ident;
    }
}
