//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg {

import com.whirled.AbstractControl;
import com.whirled.AbstractSubControl;
import com.whirled.TargetedSubControl;
import com.whirled.net.MessageReceivedEvent;

/**
 * Dispatched when a message arrives with information that is not part of the shared game state.
 *
 * @eventType com.whirled.net.MessageReceivedEvent.MESSAGE_RECEIVED
 * @see PlayerSubControlServer#sendMessage()
 */
[Event(name="MsgReceived", type="com.whirled.net.MessageReceivedEvent")]

/**
 * Provides services for the client's player of an AVRG.
 * @see AVRGameControl#player
 */
public class PlayerSubControlClient extends PlayerSubControlBase
{
    /** @private */
    public function PlayerSubControlClient (ctrl :AbstractControl)
    {
        super(ctrl, 0);
    }

    /** @inheritDoc */
    // from PlayerSubControlBase
    override public function getPlayerId () :int
    {
        return callHostCode("getPlayerId_v1");
    }

    /** @inheritDoc */
    // from PlayerSubControlBase
    override public function getPlayerName () :String
    {
        return callHostCode("getPlayerName_v1");
    }

    /**
     * Returns the master item id of the avatar being worn by the player, or zero for
     * guests (ghosts) or people wearing the default tofu. The master id will be the
     * same for all purchased copies of a particular catalog avatar and will be a
     * unique value for every original (non-catalog purchased) avatar item.
     */
    public function getAvatarMasterItemId () :int
    {
        return callHostCode("getAvatarMasterItemId_v1");
    }

    /** @private */
    override protected function setUserProps (o :Object) :void
    {
        super.setUserProps(o);

        o["taskCompleted_v1"] = taskCompleted_v1;

        // the client backend does not send in targetId
        o["player_propertyWasSet_v1"] = _props.propertyWasSet_v1;

        o["player_messageReceived_v1"] = player_messageReceived_v1;
    }

    private function player_messageReceived_v1 (name :String, value :Object, sender :int) :void
    {
        dispatch(new MessageReceivedEvent(name, value, sender));
    }
}
}
