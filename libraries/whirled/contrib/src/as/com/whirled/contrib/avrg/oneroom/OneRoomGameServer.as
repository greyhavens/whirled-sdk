package com.whirled.contrib.avrg.oneroom {

import flash.utils.Dictionary;

import com.threerings.util.Log;

import com.whirled.ServerObject;

import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.avrg.AVRServerGameControl;
import com.whirled.avrg.RoomServerSubControl;

/**
 * Server agent for games that take place in exactly one room. This means that whenever a player
 * leaves the room, he is automatically ejected from the game. To use this class, the game should
 * put something like the following in Server.as:
 *
 * <listing version="3.0">
 * import com.whirled.contrib.avrg.oneroom.OneRoomGameServer;<br>
 * public class Server extends OneRoomGameServer
 * {
 *    roomType = MyRoomType;
 * }
 * </listing>
 *
 * The <code>MyRoomType</code> in the example must be a subclass of <code>OneRoomGameRoom</code>.
 * Instances of this type will be created as needed and those instances will effectively handle
 * all game activity.
 * @see OneRoomGameRoom
 */
public class OneRoomGameServer extends ServerObject
{
    /** The log sink associated with this agent. */
    public static var log :Log = Log.getLog(OneRoomGameServer);

    /** The type of room objects to create. The caller must set this type when the server agent is
     * instantiated. The set value must be a subclass of <code>OneRoomGameRoom</code>.
     * @see OneRoomGameRoom */
    public static var roomType :Class;

    /** Creates a new server agent for a game that takes place in exactly one room. */
    public function OneRoomGameServer ()
    {
        _gameCtrl = new AVRServerGameControl(this);
        _gameCtrl.game.addEventListener(AVRGameControlEvent.PLAYER_JOINED_GAME, playerJoinedGame);
        _gameCtrl.game.addEventListener(AVRGameControlEvent.PLAYER_QUIT_GAME, playerQuitGame);
    }

    /**
     * Accesses the game control for this server agent.
     */
    public function get gameCtrl () :AVRServerGameControl
    {
        return _gameCtrl;
    }

    /**
     * Creates a new room. Subclasses should not normally need to override this.
     */
    protected function createRoom (roomId :int) :OneRoomGameRoom
    {
        if (roomType == null) {
            throw new Error("Room type not set");
        }
        var room :OneRoomGameRoom = new roomType();
        room.init(this, roomId);
        return room;
    }

    /**
     * Tells the agent that a player has joined the game. This is called by whirled and subclasses
     * should not normally need to override it.
     */
    protected function playerJoinedGame (evt :AVRGameControlEvent) :void
    {
        var playerId :int = evt.value as int;
        _gameCtrl.getPlayer(playerId).addEventListener(
            AVRGamePlayerEvent.ENTERED_ROOM, enteredRoom);
        _gameCtrl.getPlayer(playerId).addEventListener(
            AVRGamePlayerEvent.LEFT_ROOM, leftRoom);
    }

    /**
     * Tells the agent that a player has quit the game. This is called by whirled and subclasses
     * should not normally need to override it.
     */
    protected function playerQuitGame (evt :AVRGameControlEvent) :void
    {
        var playerId :int = evt.value as int;
        _gameCtrl.getPlayer(playerId).removeEventListener(
            AVRGamePlayerEvent.ENTERED_ROOM, enteredRoom);
        _gameCtrl.getPlayer(playerId).removeEventListener(
            AVRGamePlayerEvent.ENTERED_ROOM, leftRoom);
    }

    /**
     * Tells the agent that a player has entered a room. Takes care of creating a new room object
     * if one does not already exist. This is called by whirled and subclasses should not normally
     * need to override it.
     * @see #roomType
     */
    protected function enteredRoom (evt :AVRGamePlayerEvent) :void
    {
        var roomId :int = evt.value as int;
        if (_rooms[roomId] == null) {
            _rooms[roomId] = createRoom(roomId);
        }
    }

    /**
     * Tells the agent that a player has left a room. If this is the last player in the room, then
     * calls <code>OneRoomGameRoom.shutdown</code>. This is called by whirled and subclasses should
     * not normally need to override it.
     * @see OneRoomGameRoom.shutdown
     */
    protected function leftRoom (evt :AVRGamePlayerEvent) :void
    {
        var roomId :int = evt.value as int;
        var playersInRoom :Array = _gameCtrl.getRoom(roomId).getPlayerIds();
        if (playersInRoom.length == 0) {
            _rooms[roomId].shutdown();
            delete _rooms[roomId];
        }
        _gameCtrl.getPlayer(evt.playerId).deactivateGame();
    }

    /** Mapping of room ids to OneRoomGameRoom instances. */
    protected var _rooms :Dictionary = new Dictionary();

    /** The game control for this server agent. */
    protected var _gameCtrl :AVRServerGameControl;
}
}
