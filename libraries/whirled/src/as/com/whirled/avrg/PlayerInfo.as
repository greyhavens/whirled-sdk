//
// $Id$

package com.whirled.avrg {

public class PlayerInfo
{
    /** The player's id. */
    public var id :int;

    /** The player's name (not unique). */
    public var name :String;

    /** The player's party id, or 0 if none. */
    public var partyId :int;

    /** The player's party's name (not unique), or null if none. */
    public var partyName :String;

    /** The group id of the party, or 0. */
    public var groupId :int;
    
    /** The group name (not unique) of the party, or null. */
    public var groupName :String;
}
}
