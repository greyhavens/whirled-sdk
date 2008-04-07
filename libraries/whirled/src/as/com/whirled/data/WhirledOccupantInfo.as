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
     * NOTE that this method is only here because we don't have MediaDesc
     * out in com.whirled land. If using one of these objects inside
     * whirled, you should use the getHeadshot() method in preference.
     */
    function getHeadshotURL () :String;
}
}
