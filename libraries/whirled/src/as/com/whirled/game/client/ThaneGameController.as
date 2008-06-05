//
// $Id$

package com.whirled.game.client {

import com.threerings.util.Log;
import com.threerings.util.Name;
import com.threerings.util.Controller;
import com.threerings.presents.dobj.AttributeChangeListener;
import com.threerings.presents.dobj.AttributeChangedEvent;
import com.threerings.bureau.util.BureauContext;
import com.threerings.parlor.game.data.GameObject;
import com.threerings.parlor.turn.client.TurnGameControllerDelegate;
import com.whirled.game.data.ThaneGameConfig;
import com.whirled.game.data.WhirledGameObject;

/**
 * A controller for thane whirled games.
 */
public class ThaneGameController extends Controller
    implements AttributeChangeListener
{
    /** The backend we dispatch game events to. */
    public var backend :ThaneGameBackend;

    /** Creates a new controller. The controller is not usable until <code>init</code> is 
     *  called. */
    public function ThaneGameController ()
    {
    }

    /** Initializes the controller. */
    public function init (
        ctx :BureauContext, 
        gameObj :WhirledGameObject, 
        config :ThaneGameConfig) :void
    {
        _ctx = ctx;
        _gameObj = gameObj;
        _config = config;

        backend = new ThaneGameBackend(_ctx, _gameObj, this);

        _gameObj.addListener(this);

        _thfield = _gameObj.getTurnHolderFieldName();
    }

    /** Shuts down the game controller. */
    public function shutdown () :void
    {
        _gameObj.removeListener(this);

        backend.shutdown();

        _gameObj = null;
    }

    /**
     * Called after we've entered the game and everything has initialized
     * to notify the server that we, as an agent, are ready.
     */
    public function agentReady () :void
    {
        _log.info("Reporting agent ready " + _gameObj.which() + ".");
        _gameObj.manager.invoke("agentReady");
    }


    /** Access the game configuration. */
    public function getConfig () :ThaneGameConfig
    {
        return _config;
    }

    // from interface AttributeChangeListener
    public function attributeChanged (event :AttributeChangedEvent) :void
    {
        var name :String = event.getName();

        if (WhirledGameObject.CONTROLLER_OID == name) {
            backend.controlDidChange();

        } else if (GameObject.ROUND_ID == name) {
            if ((event.getValue() as int) > 0) {
                backend.roundStateChanged(true);
            } else {
                backend.roundStateChanged(false);
            }

        } else if (GameObject.STATE == name) {
            var newState :int = int(event.getValue());
            if (!stateDidChange(newState)) {
                _log.warning("Game transitioned to unknown state " +
                             "[gameObj=" + _gameObj + ", state=" + newState + "].");
            }

        } else if (name == _thfield) {
            var thname :Name = (event.getValue() as Name);
            var othname :Name = (event.getOldValue() as Name);
            if (TurnGameControllerDelegate.TURN_HOLDER_REPLACED.equals(thname) ||
                TurnGameControllerDelegate.TURN_HOLDER_REPLACED.equals(othname)) {
                // small hackery: ignore the turn holder being set to
                // TURN_HOLDER_REPLACED as it means that we're replacing
                // the current turn holder rather than switching turns;
                // also ignore the new turn holder when we switch from THR
                // to a real name again
            } else {
                turnDidChange(thname);
            }
        }

    }

    /** Called when the turn holder field changes. */
    protected function turnDidChange (turnHolder :Name) :void
    {
        backend.turnDidChange();
    }

    /** Called after the game state changes. Returns true if the change was recognized. */
    protected function stateDidChange (state :int) :Boolean
    {
        switch (state) {
        case GameObject.PRE_GAME:
            return true;
        case GameObject.IN_PLAY:
            gameDidStart();
            return true;
        case GameObject.GAME_OVER:
            gameDidEnd();
            return true;
        case GameObject.CANCELLED:
            gameWasCancelled();
            return true;
        }
        return false;
    }

    /**
     * Called when the game transitions to the <code>IN_PLAY</code>
     * state. This happens when all of the players have arrived and the
     * server starts the game.
     */
    protected function gameDidStart () :void
    {
        if (_gameObj == null) {
            _log.info("Received gameDidStart() after ending game.");

        } else {
            // clear out our game over flag
            setGameOver(false);
        }

        backend.gameStateChanged(true);
    }

    /**
     * Called when the game transitions to the <code>GAME_OVER</code>
     * state. This happens when the game reaches some end condition by
     * normal means (is not cancelled or aborted).
     */
    protected function gameDidEnd () :void
    {
        backend.gameStateChanged(false);
    }

    /**
     * Called when the game was cancelled for some reason.
     */
    protected function gameWasCancelled () :void
    {
    }

    /**
     * Sets the client game over override. This is used in situations
     * where we determine that the game is over before the server has
     * informed us of such.
     */
    public function setGameOver (gameOver :Boolean) :void
    {
        _gameOver = gameOver;
    }

    protected var _ctx :BureauContext;
    protected var _gameObj :WhirledGameObject;
    protected var _config :ThaneGameConfig;

    /** A local flag overriding the game over state for situations where
     * the client knows the game is over before the server has
     * transitioned the game object accordingly. */
    protected var _gameOver :Boolean;

    /** The name of the turn holder field. */
    protected var _thfield :String;

    protected static const _log :Log = Log.getLog(ThaneGameController);
}
}
