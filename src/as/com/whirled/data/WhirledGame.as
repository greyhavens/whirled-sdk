//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.data {

import com.threerings.presents.dobj.DSet;

/**
 * Games that wish to make use of Whirled game services should have their {@link GameObject}
 * derivation implement this interface.
 */
public interface WhirledGame
{
    /**
     * Returns the {@link WhirledGameService} used by this game.
     */
    function getWhirledGameService () :WhirledGameMarshaller;

    /**
     * Returns the list of {@link GameData} records available to this game.
     */
    function getGameData () :Array;

    /**
     * Returns the set of {@link Ownership} records for this game.
     */
    function getGameDataOwnership () :DSet;
}
}
