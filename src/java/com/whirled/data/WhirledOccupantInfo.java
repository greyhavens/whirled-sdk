//
// $Id$

package com.whirled.data;

/**
 * Provides information on occupants in a Whirled game.
 */
public interface WhirledOccupantInfo
{
    /**
     * Returns a URL that can be loaded to obtain an avatar headshot for this occupant.
     */
    public String getHeadshotURL ();
}
