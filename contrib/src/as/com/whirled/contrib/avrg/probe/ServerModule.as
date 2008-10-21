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

package com.whirled.contrib.avrg.probe {

import flash.utils.Dictionary;

import flash.events.Event;
import flash.events.IEventDispatcher;

import com.threerings.util.StringUtil;

import com.whirled.ServerObject;
import com.whirled.net.MessageReceivedEvent;
import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.avrg.AVRGameRoomEvent;
import com.whirled.avrg.AVRServerGameControl;
import com.whirled.avrg.RoomSubControlServer;

/**
 * Object to serve the <code>ClientPanel</code>'s request to invoke server API calls. Methods and
 * their arguments are sent in messages, the method looked up in <code>ServerDefinitions</code>
 * and called and the result or error sent back to the client in another message. Also does very
 * basic tracking of the game's currently active players and rooms so that all their events can
 * listened for and logged.
 * @see com.whirled.contrib.avrg.probe.ServerDefinitions
 * @see com.whirled.contrib.avrg.probe.ClientPanel
 */
public class ServerModule
{
    /** Message name for invoking a server agent API method. */
    public static const REQUEST_BACKEND_CALL :String = "request.backend.call";

    /** Message name for sending the results of a invoking a server agent API method back to the 
     * client. */
    public static const BACKEND_CALL_RESULT :String = "backend.call.result";

    /** Message name for sending the arguments passed to a callback parameter back to the
     * client. */
    public static const CALLBACK_INVOKED :String = "callback.invoked";

    /**
     * Creates a new server module, targeting a given game control.
     */
    public function ServerModule (ctrl :AVRServerGameControl)
    {
        _ctrl = ctrl;
        _defs = new ServerDefinitions(_ctrl);
    }

    public function activate () :void
    {
        if (_active) {
            return;
        }

        _active = true;

        _ctrl.game.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, handleGameMessage);
        _ctrl.game.addEventListener(AVRGameControlEvent.PLAYER_JOINED_GAME, handlePlayerJoin);
        _ctrl.game.addEventListener(AVRGameControlEvent.PLAYER_QUIT_GAME, handlePlayerQuit);

        addLogger(_ctrl.game, ServerDefinitions.GAME_EVENTS);
        addLogger(_ctrl.game.props, ServerDefinitions.NET_EVENTS);

        for each (var playerId :int in _ctrl.game.getPlayerIds()) {
            watchPlayer(playerId);
        }

        trace("ServerModule activated");
    }

    public function deactivate () :void
    {
        if (!_active) {
            return;
        }

        _active = false;

        _ctrl.game.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, handleGameMessage);
        _ctrl.game.removeEventListener(AVRGameControlEvent.PLAYER_JOINED_GAME, handlePlayerJoin);
        _ctrl.game.removeEventListener(AVRGameControlEvent.PLAYER_QUIT_GAME, handlePlayerQuit);

        removeLogger(_ctrl.game, ServerDefinitions.GAME_EVENTS);
        removeLogger(_ctrl.game.props, ServerDefinitions.NET_EVENTS);

        for each (var playerId :int in _ctrl.game.getPlayerIds()) {
            unwatchPlayer(playerId);
        }

        for (var roomId :* in _roomOccupantCounts) {
            if (_roomOccupantCounts[roomId] > 0) {
                unwatchRoom(roomId as int);
            }
        }

        _playerRooms = new Dictionary();
        _roomOccupantCounts = new Dictionary();

        trace("ServerModule deactivated");
    }

    protected function handleGameMessage (evt :MessageReceivedEvent) :void
    {
        if (evt.name == REQUEST_BACKEND_CALL) {
            trace("Handling message " + evt);
            var result :Object = {};
            result.sequenceId = evt.value.sequenceId;
            var fnSpec :FunctionSpec = _defs.findByName(evt.value.name);
            if (fnSpec == null) {
                result.status = "failed";
                result.reason = "Function " + evt.name + " not found";

            } else {
                var args :Array = evt.value.params;
                var params :Array = fnSpec.parameters;
                for (var ii :int = 0; ii < args.length; ++ii) {
                    if (params[ii] is CallbackParameter && args[ii] != null) {
                        args[ii] = makeGenericCallback(evt.value, evt.senderId);
                    }
                }

                trace("Calling " + fnSpec.name + " (" + evt.value.name + ") with arguments " + 
                      StringUtil.toString(args));
                try {
                    var value :Object = fnSpec.func.apply(null, args);
                    trace("Result: " + StringUtil.toString(value));
                    result.status = "succeeded";
                    result.result = value;

                } catch (e :Error) {
                    var msg :String = e.getStackTrace();
                    if (msg == null) {
                        msg = e.toString();
                    }
                    trace(msg);
                    result.status = "failed";
                    result.reason = "Function raised an exception:\n" + msg;
                }
            }

            trace("Sending message " + BACKEND_CALL_RESULT + " to " + evt.senderId + ", value " + StringUtil.toString(result));
            _ctrl.getPlayer(evt.senderId).sendMessage(BACKEND_CALL_RESULT, result);
        }
    }

    protected function handlePlayerJoin (event :AVRGameControlEvent) :void
    {
        watchPlayer(event.value as int);
    }

    protected function watchPlayer (playerId :int) :void
    {
        _ctrl.getPlayer(playerId).addEventListener(
            AVRGamePlayerEvent.ENTERED_ROOM, handleRoomEntry);
        _ctrl.getPlayer(playerId).addEventListener(
            AVRGamePlayerEvent.LEFT_ROOM, handleRoomExit);

        addLogger(_ctrl.getPlayer(playerId), ServerDefinitions.PLAYER_EVENTS);
        addLogger(_ctrl.getPlayer(playerId).props, ServerDefinitions.NET_EVENTS);
    }

    protected function handlePlayerQuit (event :AVRGameControlEvent) :void
    {
        unwatchPlayer(event.value as int);
    }

    protected function unwatchPlayer (playerId :int) :void
    {
        _ctrl.getPlayer(playerId).removeEventListener(
            AVRGamePlayerEvent.ENTERED_ROOM, handleRoomEntry);
        _ctrl.getPlayer(playerId).removeEventListener(
            AVRGamePlayerEvent.LEFT_ROOM, handleRoomExit);

        removeLogger(_ctrl.getPlayer(playerId), ServerDefinitions.PLAYER_EVENTS);
        removeLogger(_ctrl.getPlayer(playerId).props, ServerDefinitions.NET_EVENTS);
    }

    protected function handleRoomEntry (event :AVRGamePlayerEvent) :void
    {
        var playerId :int = event.playerId;
        var roomId :int = event.value as int;
        _playerRooms[playerId] = roomId;
        _roomOccupantCounts[roomId] = int(_roomOccupantCounts[roomId]) + 1;
        trace("Player entered room, occupant count is now " + _roomOccupantCounts[roomId]);
        if (_roomOccupantCounts[roomId] == 1) {
            watchRoom(roomId);
        }
    }

    protected function watchRoom (roomId :int) :void
    {
        addLogger(_ctrl.getRoom(roomId), ServerDefinitions.ROOM_EVENTS);
        addLogger(_ctrl.getRoom(roomId).props, ServerDefinitions.NET_EVENTS);
    }

    protected function handleRoomExit (event :AVRGamePlayerEvent) :void
    {
        var playerId :int = event.playerId;
        var roomId :int = _playerRooms[playerId] as int;
        _playerRooms[playerId] = 0;
        _roomOccupantCounts[roomId] = int(_roomOccupantCounts[roomId]) - 1;
        trace("Player left room, occupant count is now " + _roomOccupantCounts[roomId]);
        if (_roomOccupantCounts[roomId] == 0) {
            unwatchRoom(roomId);
        }
    }

    protected function unwatchRoom (roomId :int) :void
    {
        removeLogger(_ctrl.getRoom(roomId), ServerDefinitions.ROOM_EVENTS);
        removeLogger(_ctrl.getRoom(roomId).props, ServerDefinitions.NET_EVENTS);
    }

    protected function logEvent (event :Event) :void
    {
        trace("Event received: " + event);
    }

    protected function makeGenericCallback (
        origMessage :Object,
        senderId :int) :Function
    {
        function callback (...args) :void {
            trace("Callback from " + origMessage.name + " invoked with " + 
                  "arguments " + StringUtil.toString(args));
            var msg :Object = {};
            msg.name = origMessage.name;
            msg.sequenceId = origMessage.sequenceId;
            msg.args = args;
            _ctrl.getPlayer(senderId).sendMessage(CALLBACK_INVOKED, msg);
        }

        return callback;
    }

    protected function addLogger (ctrl :IEventDispatcher, events :Array) :void
    {
        for each (var type :String in events) {
            ctrl.addEventListener(type, logEvent);
        }
    }

    protected function removeLogger (ctrl :IEventDispatcher, events :Array) :void
    {
        for each (var type :String in events) {
            ctrl.removeEventListener(type, logEvent);
        }
    }

    protected var _ctrl :AVRServerGameControl;
    protected var _defs :ServerDefinitions;
    protected var _active :Boolean;
    protected var _playerRooms :Dictionary = new Dictionary();
    protected var _roomOccupantCounts :Dictionary = new Dictionary();
}

}

