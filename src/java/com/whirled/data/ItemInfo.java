//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.data;

import com.threerings.io.SimpleStreamableObject;

import com.threerings.presents.dobj.DSet;

/**
 * Contains information on an item pack available to this game.
 */
public class ItemInfo extends SimpleStreamableObject
    implements DSet.Entry
{
    /** A unique identifier for this pack. */
    public String ident;

    /** A human readable name for this pack. */
    public String name;

    /** The URL from which this pack's media can be downloaded. */
    public String mediaURL;

    // from interface DSet.Entry
    public Comparable getKey ()
    {
        return ident;
    }
}
