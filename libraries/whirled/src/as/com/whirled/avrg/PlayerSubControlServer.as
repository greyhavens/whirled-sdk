//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg {

import com.whirled.AbstractControl;

import com.whirled.avrg.PlayerSubControlBase;

import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.MessageSubControl;
import com.whirled.net.PropertySubControl;
import com.whirled.net.impl.PropertySubControlImpl;

public class PlayerSubControlServer extends PlayerSubControlBase
    implements MessageSubControl
{
    /** @private */
    public function PlayerSubControlServer (ctrl :AbstractControl, targetId :int)
    {
        super(ctrl, targetId);
    }

    public function getPlayerId () :int
    {
        return _targetId;
    }

    /**
     * Awards the specified trophy to this client's player (the default) or a specified player.
     * If the supplied trophy identifier is not valid, this will not be known until the request is
     * processed on the server, so the method will return succcessfully but no trophy will have
     * been awarded. Thus, you should be careful not to misspell your trophy identifier in your
     * code or in the associated trophy source item.
     *
     * @return true if the trophy was awarded, false if the player already has that trophy.
     */
    public function awardTrophy (ident :String) :Boolean
    {
        return (callHostCode("awardTrophy_v1", ident) as Boolean);
    }

    /**
     * Awards the specified prize item to this client's player (the default) or a specified player.
     * If the supplied prize identifier is not valid, this will not be known until the request is
     * processed on the server, so the method will return successfully but no prize will have been
     * awarded. Thus you should be careful not to misspell your prize identifier in your code or in
     * the associated prize item.
     *
     * <p> Note: a game is only allowed to award a prize once per game session. This is to guard
     * against bugs that might try to award many hundreds of the same prize to a user while playing
     * a game. If you *really* want to award multiple instances of a prize, you will need to make
     * different prize items with unique identifiers which all reference the same target item. </p>
     *
     * <p> Note also: because a game *can* award the same prize more than once if the player earns
     * the prize in separate game sessions, a game that wishes to only award a prize once should
     * couple the award of the prize with the award of a trophy and then structure their code like
     * so: </p>
     *
     * <pre>
     * if (_ctrl.awardTrophy("special_award_trophy")) {
     *     _ctrl.awardPrize("special_award_avatar");
     * }
     * </pre>
     *
     * <p> The first time the player accomplishes the necessary goal, they will be awarded the
     * trophy and the prize. Subsequently, awardTrophy() will return false indicating that the
     * player already has the trophy in question and the prize will not be awarded. Alternatively
     * the game could store whether or not the player has earned the prize in a user cookie. </p>
     */
    public function awardPrize (ident :String) :void
    {
        callHostCode("awardPrize_v1", ident);
    }

    /** Sends a message to this player only. */
    public function sendMessage (name :String, value :Object = null) :void
    {
        callHostCode("player_sendMessage_v1", name, value);
    }

    internal function gotHostPropsFriend (o :Object) :void
    {
        gotHostProps(o);
    }
}
}
