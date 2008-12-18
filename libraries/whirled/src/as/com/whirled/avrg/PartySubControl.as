//
// $Id$

package com.whirled.avrg {

import com.whirled.AbstractSubControl;

public class PartySubControl extends AbstractSubControl
{
    /** @private */
    public function PartySubControl (parent :GameSubControlBase)
    {
        super(parent);
    }

    /**
     * Get the party id. You should know this, or how did you get this subcontrol?
     */
    public function getId () :int
    {
        return 0; // TODO
    }

    /**
     * Get the name of this party. This is not guaranteed to be unique.
     */
    public function getName () :String
    {
        return "TODO";
    }

    /**
     * Get the group id of this party. Note that different parties could have the same group id.
     */
    public function getGroupId () :int
    {
        return 0; // TODO
    }

    /**
     * Get the name of the group hosting this party.
     */
    public function getGroupName () :String
    {
        return "TODO";
    }

    /**
     * Get the leader of this party.
     */
    public function getLeaderId () :int
    {
        return 0; // TODO
    }

    /**
     * Get the player ids in this party.
     */
    public function getPlayerIds () :Array /* of int */
    {
        return []; // TODO
        // TODO: sort? So leader is first?
    }
}
}
