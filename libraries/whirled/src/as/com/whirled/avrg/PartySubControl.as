//
// $Id$

package com.whirled.avrg {

import flash.events.Event;

import flash.display.DisplayObject;

import com.whirled.TargetedSubControl;

/**
 * Dispatched when a player arrives in this party.
 *
 * @eventType com.whirled.avrg.AVRGameControlEvent.PLAYER_ENTERED_PARTY
 */
[Event(name="playerEnteredParty", type="com.whirled.avrg.AVRGameControlEvent")]

/**
 * Dispatched when a player leaves this party.
 *
 * @eventType com.whirled.avrg.AVRGameControlEvent.PLAYER_LEFT_PARTY
 */
[Event(name="playerLeftParty", type="com.whirled.avrg.AVRGameControlEvent")]

/**
 * Provides services on a particular party.
 */
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

    /**
     * Attempt to move the entire party to a new room. You cannot make them appear to leave
     * via exit coords.
     *
     * <p>Hard-wiring valid room ids should be avoided. Room ids can be obtained from properties
     * stored by an admininstrative interface or from a server agent message containing currently
     * active rooms.</p>
     */
    public function moveToRoom (roomId :int) :void
    {
        callHostCode("party_moveToRoom_v1", roomId);
    }

    /** @private */
    internal function gotHostPropsFriend (o :Object) :void
    {
        gotHostProps(o);
    }

    /** @private */
    internal function dispatchFriend (event :Event) :void
    {
        super.dispatch(event);
    }
}
}
