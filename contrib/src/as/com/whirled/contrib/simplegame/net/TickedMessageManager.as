// Whirled contrib library - tools for developing whirled games
// http://www.whirled.com/code/contrib/asdocs
//
// This library is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library.  If not, see <http://www.gnu.org/licenses/>.
//
// Copyright 2008 Three Rings Design
//
// $Id$

package com.whirled.contrib.simplegame.net {

import com.whirled.game.NetSubControl;

import com.whirled.contrib.simplegame.Updatable;

public interface TickedMessageManager extends Updatable
{
    /**
     * Should be called when the the TickedMessageManager should start listening for and
     * and processing game ticks. In a multiplayer game, this is usually immediately after the
     * GAME_STARTED event is received.
     */
    function run () :void;

    /**
     * Stops the TickedMessageManager from processing game ticks. The manager can be restarted
     * by calling run() again.
     */
    function stop () :void;

    /**
     * Returns true when the TickedMessageManager is ready to begin sending and receiving messages.
     * This will happen after run() is called, but not necessarily immediately, depending on any
     * network handshaking that needs to happen.
     */
    function get isReady () :Boolean;

    /**
     * @return the number of ticks that the game hasn't yet retrieved with getNextTick().
     * @see #getNextTick
     */
    function get unprocessedTickCount () :uint;

    /**
     * @return an Array containing the messages that were received during the oldest unprocessed
     * tick, or null if there are no unprocessed ticks remaining.
     */
    function getNextTick () :Array;

    /**
     * Registers a message type with the TickedMessageManager. Shortly after setup() is called,
     * this function should be called once for each message type that the game will send or
     * receive.
     */
    function addMessageType (messageClass :Class) :void;

    /**
     * Sends a message to the specified players.
     */
    function sendMessage (msg :Message, playerId :int = NetSubControl.TO_ALL) :void;

    /**
     * @return true if a call to sendMessage() will succeed. Games generally don't need to be
     * concerned with this function; it should only return false if the TickedMessageManager is
     * overloaded with too many pending messages.
     */
    function canSendMessage () :Boolean;
}

}
