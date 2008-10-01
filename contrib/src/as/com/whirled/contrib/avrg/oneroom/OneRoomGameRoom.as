package com.whirled.contrib.avrg.oneroom {

import com.threerings.util.Log;
import com.threerings.util.ClassUtil;

import com.whirled.net.MessageReceivedEvent;
import com.whirled.avrg.AVRServerGameControl;
import com.whirled.avrg.RoomSubControlServer;
import com.whirled.avrg.AVRGameRoomEvent;

/**
 * Room type superclass for games that take place in exactly one room. To use this class, games
 * should create a subclass and set it as the roomType in the server agent. The subclass just
 * needs to handle game logic in the given hooks, something like this:
 *
 * <listing version="3.0">
 * import com.whirled.contrib.avrg.oneroom.OneRoomGameRoom;<br>
 * public class MyRoom extends OneRoomGameRoom
 * {
 *     override public function finishInit ()
 *     {
 *         super.finishInit();
 *         // game initialization code
 *     } <br>
 *     override public function shutdown ()
 *     {
 *         // game shutdown code
 *         super.shutdown();
 *     } <br>
 *     override protected function messageReceived (
 *         senderId :int, name :String, value :Object) :void
 *     {
 *         // game logic for when a message is received from a player, for example:
 *         if (name == MOVE) {
 *             _myState.applyChange(value as Move);
 *             _roomCtrl.props.set(GAMESTATE, _myState.toObject());
 *         }
 *     } <br>
 *     override public function playerEntered (playerId :int)
 *     {
 *         // game logic for when a new player comes in the room
 *     } <br>
 *     override public function playerLeft (playerId :int)
 *     {
 *         // game logic for when a new player leaves the room
 *     }
 * }
 * </listing>
 * @see OneRoomGameServer
 */
public class OneRoomGameRoom
{
    /** The log associated with this room. Includes a time stamp and a prefix with the id of the
     * room. */
    public var log :Log;

    /** 
     * Intializes the game room. Subclasses should not need to override this, but should initialize
     * game specific members in <code>finishInit</code>.
     * @see #finishInit
     */
    public function init (server :OneRoomGameServer, roomId :int) :void
    {
        _server = server;
        _gameCtrl = server.gameCtrl;
        _roomCtrl = _gameCtrl.getRoom(roomId);

        log = Log.getLog(ClassUtil.getClassName(this) + " [room " + roomId + "]");
        log.info("Starting up");

        _roomCtrl.addEventListener(AVRGameRoomEvent.PLAYER_ENTERED, translatePlayerEntered);
        _roomCtrl.addEventListener(AVRGameRoomEvent.PLAYER_LEFT, translatePlayerLeft);
        _gameCtrl.game.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, translateMessage);

        finishInit();
    }

    /**
     * Shuts down the game room. Subclasses should override and remove listeners and clear state
     * variables etc., ensuring that <code>super.shutdown</code> is called at the end.
     */
    public function shutdown () :void
    {
        log.info("Shutting down");

        // remove our listeners
        _roomCtrl.removeEventListener(AVRGameRoomEvent.PLAYER_ENTERED, translatePlayerEntered);
        _roomCtrl.removeEventListener(AVRGameRoomEvent.PLAYER_LEFT, translatePlayerLeft);
        _gameCtrl.game.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, translateMessage);

        _server = null;
        _gameCtrl = null;
        _roomCtrl = null;
    }

    /**
     * Called once the room is initialized. Callers should override and set up game-specific state
     * and objects etc., ensuring that <code>super.finishInit</code> is called first.
     */
    protected function finishInit () :void
    {
    }

    /**
     * Called whan a game player in this room sends a message to the server agent. Subclasses should
     * override and perform handling for game messages.
     */
    protected function messageReceived (senderId :int, name :String, value :Object) :void
    {
    }

    /**
     * Called whan a game player enters the room. Subclasses should override and update their
     * internal state for the addition of the player.
     */
    protected function playerEntered (playerId :int) :void
    {
    }

    /**
     * Called whan a game player leaves the room. Subclasses should override and update their
     * internal state for the removal of the player.
     */
    protected function playerLeft (playerId :int) :void
    {
    }

    /**
     * Called by whirled when a player sends a message. If the message sender is in this room,
     * calls <code>messageReceived</code>. 
     * @private
     */
    protected function translateMessage (evt :MessageReceivedEvent) :void
    {
        var playerId :int = evt.senderId;
        if (_roomCtrl.isPlayerHere(playerId)) {
            messageReceived(evt.senderId, evt.name, evt.value);
        }
    }

    /**
     * Called by whirled when a player enters the room. Calls <code>playerEntered</code>.
     * @private
     */
    protected function translatePlayerEntered (evt :AVRGameRoomEvent) :void
    {
        if (evt.roomId != _roomCtrl.getRoomId()) {
            log.warning("Wrong room in event [evt=" + evt + "]");
            return;
        }
        playerEntered(evt.value as int);
    }

    /**
     * Called by whirled when a player leaves the room. Calls <code>playerLeft</code>.
     * @private
     */
    protected function translatePlayerLeft (evt :AVRGameRoomEvent) :void
    {
        if (evt.roomId != _roomCtrl.getRoomId()) {
            log.warning("Wrong room in event [evt=" + evt + "]");
            return;
        }
        playerLeft(evt.value as int);
    }

    /** The room control for this room. */
    protected var _roomCtrl :RoomSubControlServer;

    /** The game control for the agent. */
    protected var _gameCtrl :AVRServerGameControl;

    /** The agent that spawned this room. */
    protected var _server :OneRoomGameServer;
}
}
