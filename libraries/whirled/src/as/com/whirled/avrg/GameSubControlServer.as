//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg {

import flash.events.Event;

import com.whirled.AbstractControl;

import com.whirled.net.MessageSubControl;
import com.whirled.net.PropertySubControl;
import com.whirled.net.impl.PropertyGetSubControlImpl;

import com.whirled.net.impl.PropertySubControlImpl;

/**
 * Dispatched when a new player joins the game.
 *
 * @eventType com.whirled.avrg.AVRGameControlEvent.PLAYER_JOINED_GAME
 */
[Event(name="playerJoinedGame", type="com.whirled.avrg.AVRGameControlEvent")]

/**
 * Dispatched when a player leaves the game.
 *
 * @eventType com.whirled.avrg.AVRGameControlEvent.PLAYER_QUIT_GAME
 */
[Event(name="playerQuitGame", type="com.whirled.avrg.AVRGameControlEvent")]

/**
 * Provides services for AVR game server agents.
 */
public class GameSubControlServer extends GameSubControlBase
    implements MessageSubControl
{
    /** @private */
    public function GameSubControlServer (ctrl :AbstractControl)
    {
        super(ctrl);
    }

    /**
     * Accesses the global properties for this game.
     */
    public function get props () :PropertySubControl
    {
        return _props;
    }

    /**
     * Sends a message to all players in this game. Use carefully since the resulting outgoing
     * message load could be significant. Games that overload the server are subject to
     * discretionary action.
     */
    public function sendMessage (name :String, value :Object = null) :void
    {
        callHostCode("game_sendMessage_v1", name, value);
    }

    /** @private */
    internal function dispatchFriend (event :Event) :void
    {
        super.dispatch(event);
    }

    /** @private */
    override protected function createSubControls () :Array
    {
        _props = new PropertySubControlImpl(
            _parent, 0, "game_getGameData_v1", "game_setProperty_v1");
        return [ _props ];
    }

    /** @private */
    protected var _props :PropertySubControlImpl;
}
}
