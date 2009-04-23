//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg {

import com.threerings.util.WeakValueHashMap;

import com.whirled.AbstractControl;
import com.whirled.AbstractSubControl;
import com.whirled.net.MessageReceivedEvent;

/**
 * Dispatched when a message arrives with information that is not part of the shared game state.
 *
 * @eventType com.whirled.net.MessageReceivedEvent.MESSAGE_RECEIVED
 * @see GameSubControlServer#sendMessage
 * @see AgentSubControl#sendMessage
 */
[Event(name="MsgReceived", type="com.whirled.net.MessageReceivedEvent")]

/**
 * Dispatched when a party arrives in the game.
 *
 * @eventType com.whirled.avrg.AVRGameControlEvent.PARTY_ENTERED
 */
[Event(name="partyEntered", type="com.whirled.avrg.AVRGameControlEvent")]

/**
 * Dispatched when a party leaves the game.
 *
 * @eventType com.whirled.avrg.AVRGameControlEvent.PARTY_LEFT
 */
[Event(name="partyLeft", type="com.whirled.avrg.AVRGameControlEvent")]

/**
 * Provides AVR game services for server agents and clients.
 */
public class GameSubControlBase extends AbstractSubControl
{
    /** @private */
    public function GameSubControlBase (ctrl :AbstractControl)
    {
        super(ctrl);
    }

    /**
     * Returns an array of the ids of all players who have joined and not yet quit the game.
     */
    public function getPlayerIds () :Array
    {
        return callHostCode("game_getPlayerIds_v1") as Array;
    }

    /**
     * Get the name of an occupant of the game, or null if not found.
     * In an AVRG all occupants are players, so this could be called getPlayerName(),
     * but this name matches RoomSubControlBase as well as the "regular" game api.
     *
     * NOTE: names are not unique and can change at any time. You must use the playerId to
     * identify someone, and only retrieve the name for display purposes.
     */
    public function getOccupantName (playerId :int) :String
    {
        return callHostCode("game_getOccupantName_v1", playerId) as String;
    }

    /**
     * Return the ids of all parties presently in this game.
     */
    public function getPartyIds () :Array /* of int */
    {
        return callHostCode("game_getPartyIds_v1");
    }

    /**
     * Get the party control for the specified party. Note that this will always
     * return a PartySubControl, even for partyIds that are not present in the game.
     * Be careful.
     */
    public function getParty (partyId :int) :PartySubControl
    {
        var ctrl :PartySubControl = _parties.get(partyId);
        if (ctrl == null) {
            ctrl = new PartySubControl(this, partyId);
            ctrl.gotHostProps(_funcs);
            _parties.put(partyId, ctrl);
        }
        return ctrl;
    }

    /**
     * Returns the set of all level packs available to this game as an array of objects with the
     * following properties:
     *
     * <pre>
     * ident - string identifier of item pack
     * name - human readable name of item pack
     * mediaURL - URL for item pack content
     * premium - boolean indicating that content is premium or not
     * </pre>
     */
    public function getLevelPacks () :Array
    {
        return (callHostCode("getLevelPacks_v2") as Array);
    }

    /**
     * Returns the set of all item packs available to this game as an array of objects with the
     * following properties:
     *
     * <pre>
     * ident - string identifier of item pack
     * name - human readable name of item pack
     * mediaURL - URL for item pack content
     * </pre>
     */
    public function getItemPacks () :Array
    {
        return (callHostCode("getItemPacks_v1") as Array);
    }

    /**
     * Loads the binary data for the level pack with the specified ident.
     *
     * @param ident the identifier of the level pack to be loaded.
     * @param onLoaded a function with the signature: function (data :ByteArray) :void
     * that will be called with the level pack data if it loads successfully.
     * @param onFailure a function with the signature: function (error :Error) :void
     * that will be called if the pack loading fails.
     */
    public function loadLevelPackData (
        ident :String, onLoaded :Function, onFailure :Function) :void
    {
        if (onLoaded == null) {
            throw new Error("The onLoaded callback may not be null");
        }
        callHostCode("loadLevelPackData_v1", ident, onLoaded, onFailure);
    }

    /**
     * Loads the binary data for the item pack with the specified ident.
     *
     * @param ident the identifier of the item pack to be loaded.
     * @param onLoaded a function with the signature: function (data :ByteArray) :void
     * that will be called with the item pack data if it loads successfully.
     * @param onFailure a function with the signature: function (error :Error) :void
     * that will be called if the pack loading fails.
     */
    public function loadItemPackData (
        ident :String, onLoaded :Function, onFailure :Function) :void
    {
        if (onLoaded == null) {
            throw new Error("The onLoaded callback may not be null");
        }
        callHostCode("loadItemPackData_v1", ident, onLoaded, onFailure);
    }

    /** @private */
    override protected function setUserProps (o :Object) :void
    {
        super.setUserProps(o);

        o["game_messageReceived_v1"] = messageReceived;
        o["game_partyEntered_v1"] = partyEntered_v1;
        o["game_partyLeft_v1"] = partyLeft_v1;
        o["party_playerEntered_v1"] = party_playerEntered_v1;
        o["party_playerLeft_v1"] = party_playerLeft_v1;
        o["party_leaderChanged_v1"] = party_leaderChanged_v1;
    }

    /** @private */
    protected function messageReceived (name :String, value :Object, sender :int) :void
    {
        dispatchEvent(new MessageReceivedEvent(name, value, sender));
    }

    /** @private */
    protected function partyEntered_v1 (partyId :int, ... rest) :void
    {
        dispatchEvent(new AVRGameControlEvent(AVRGameControlEvent.PARTY_ENTERED, null, partyId));
    }

    protected function partyLeft_v1 (partyId :int, ... rest) :void
    {
        dispatchEvent(new AVRGameControlEvent(AVRGameControlEvent.PARTY_LEFT, null, partyId));
    }

    /** @private */
    protected function party_playerEntered_v1 (partyId :int, playerId :int, ... rest) :void
    {
        dispatchParty(partyId, AVRGameControlEvent.PLAYER_ENTERED_PARTY, null, playerId);
    }

    /** @private */
    protected function party_playerLeft_v1 (partyId :int, playerId :int, ... rest) :void
    {
        dispatchParty(partyId, AVRGameControlEvent.PLAYER_LEFT_PARTY, null, playerId);
    }

    /** @private */
    protected function party_leaderChanged_v1 (partyId :int, playerId :int, ... rest) :void
    {
        dispatchParty(partyId, AVRGameControlEvent.PARTY_LEADER_CHANGED, null, playerId);
    }

    /**
     * Internal convenience function for dispatching events on a PartySubControl.
     * @private
     */
    protected function dispatchParty (partyId :int, event :String, name :String, arg :Object) :void
    {
        var ctrl :PartySubControl = _parties.get(partyId);
        if (ctrl != null) {
            ctrl.dispatchEvent(new AVRGameControlEvent(event, name, arg));
        }
    }

    /** @private */
    protected var _parties :WeakValueHashMap = new WeakValueHashMap();
}
}
