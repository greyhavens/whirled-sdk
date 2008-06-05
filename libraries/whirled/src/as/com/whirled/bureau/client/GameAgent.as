//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.bureau.client {

import com.threerings.bureau.client.Agent;
import com.threerings.bureau.Log;
import com.whirled.bureau.data.GameAgentObject;
import com.threerings.presents.dobj.ObjectAccessError;
import com.threerings.presents.dobj.Subscriber;
import com.threerings.presents.dobj.SubscriberAdapter;
import com.threerings.presents.util.SafeSubscriber;
import com.whirled.game.data.WhirledGameObject;
import com.whirled.bureau.util.WhirledBureauContext;
import com.whirled.game.client.ThaneGameController;

/** The container for a user's game control code. */
public class GameAgent extends Agent
{
    public function GameAgent (ctx :WhirledBureauContext)
    {
        _ctx = ctx;
    }

    // from Agent
    public override function start () :void
    {
        Log.info("Starting agent " + _agentObj);

        // subscribe to the game object
        var delegator :Subscriber = 
            new SubscriberAdapter(objectAvailable, requestFailed);

        Log.info("Subscribing to game object " + gameAgentObj.gameOid);

        _subscriber = new SafeSubscriber(gameAgentObj.gameOid, delegator);
        _subscriber.subscribe(_ctx.getDObjectManager());

        // download the code
        _ctx.getUserCodeLoader().load(
            _agentObj.code, 
            _agentObj.className, 
            gotUserCode);
    }

    // from Agent
    public override function stop () :void
    {
        Log.info("Stopping agent " + _agentObj);
        _subscriber.unsubscribe(_ctx.getDObjectManager());
        _subscriber = null;
        _gameObj = null;
        _agentObj = null;

        if (_controller != null) {
            _controller.shutdown();
            _controller = null;
        }

        if (_userCode != null) {
            _userCode.release();
            _userCode = null;
        }
    }

    /** Access the agent object, casted to a game agent object. */
    protected function get gameAgentObj () :GameAgentObject
    {
        return _agentObj as GameAgentObject;
    }

    /**
     * Callback for when the request to subscribe to the game object finishes and the object is 
     * available.
     */
    protected function objectAvailable (gameObj :WhirledGameObject) :void
    {
        Log.info("Subscribed to game object " + gameObj);
        _gameObj = gameObj;

        _controller = new ThaneGameController();
        _controller.init(_ctx, _gameObj, gameAgentObj.config);

        if (_userCode != null && _gameObj != null) {
            launchUserCode();
        }
    }

    /**
     * Callback for when the a request to subscribe to the game object fails.
     */
    protected function requestFailed (oid :int, cause :ObjectAccessError) :void
    {
        Log.warning("Could not subscribe to game object [oid=" + oid + "]");
        Log.logStackTrace(cause);
    }

    /**
     * Callback for when the user code is available.
     */
    protected function gotUserCode (userCode :UserCode) :void
    {
        if (userCode == null) {
            Log.warning("Unable to load user code [agent: " + _agentObj + "]");
            return;
        }

        _userCode = userCode;
        Log.info("Loaded user code " + _userCode);

        if (_userCode != null && _gameObj != null) {
            launchUserCode();
        }
    }

    /**
     * Called once the game object and the user code (domain) are available.
     */
    protected function launchUserCode () :void
    {
        _userCode.connect(_controller.backend.getConnectListener());
        
        if (!_controller.backend.isConnected()) {
            Log.info("Could not connect to user code");
            return;
        }

        _controller.agentReady();
    }

    protected var _subscriber :SafeSubscriber;
    protected var _ctx :WhirledBureauContext;
    protected var _gameObj :WhirledGameObject;
    protected var _userCode :UserCode;
    protected var _controller :ThaneGameController;
}

}
