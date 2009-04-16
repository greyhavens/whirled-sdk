//
// $Id$

package com.whirled.avrg {

import flash.display.DisplayObject;

import com.whirled.TargetedSubControl;

public class PartySubControl extends TargetedSubControl
{
    /** @private */
    public function PartySubControl (parent :GameSubControlBase, partyId :int)
    {
        super(parent, partyId);
    }

    /**
     * Get the party id, which is only used to identify a transient party instance. Parties
     * come and go. No permanent identification should be done with this id.
     */
    public function getId () :int
    {
        return _targetId;
    }

    /**
     * Get the name of this party. This is not guaranteed to be unique.
     * If the party is no longer present, null will be returned.
     */
    public function getName () :String
    {
        return callHostCode("party_getName_v1");
    }

    /**
     * Get the group id of this party. Note that different parties could have the same group id.
     * If the party is no longer present, 0 will be returned.
     */
    public function getGroupId () :int
    {
        return callHostCode("party_getGroupId_v1");
    }

    /**
     * Get the name of the group hosting this party. The name should be considered changeable
     * and non-unique and only used for display purposes. The group id can be used for
     * identification of a group.
     * If the party is no longer present, null will be returned.
     */
    public function getGroupName () :String
    {
        return callHostCode("party_getGroupName_v1");
    }

    /**
     * Get the group logo.
     * If the party is no longer present, null will be returned.
     */
    public function getGroupLogo () :DisplayObject
    {
        return callHostCode("party_getGroupLogo_v1");
    }

//    public function getLeaderId () :int
//    {
//        return 0; // TODO
//    }

    /**
     * Get the player ids in this party that are in this place.
     * If the party is no longer present, an empty array will be returned.
     */
    public function getPlayerIds () :Array /* of int */
    {
        return callHostCode("party_getPlayerIds_v1");
    }

    /** @private */
    internal function gotHostPropsFriend (o :Object) :void
    {
        gotHostProps(o);
    }
}
}
