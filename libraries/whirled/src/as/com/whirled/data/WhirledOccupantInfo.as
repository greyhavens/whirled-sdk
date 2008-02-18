//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.data {

/**
 * Provides information on occupants in a Whirled game.
 */
public interface WhirledOccupantInfo
{
    /**
     * Returns a URL that can be loaded to obtain an avatar headshot for this occupant.
     */
    function getHeadshotURL () :String;
}
}
