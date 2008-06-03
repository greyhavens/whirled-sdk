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

        if (_userCode != null) {
            _ctx.getUserCodeLoader().unload(_userCode);
            _userCode = null;
        }

        if (_userInstance != null) {
            // TODO: call some userProps function to terminate the agent?
            _userInstance = null;
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
    protected function gotUserCode (clazz: Class) :void
    {
        if (clazz == null) {
            Log.warning("Unable to load user code [agent: " + _agentObj + "]");
            return;
        }

        _userCode = clazz;
        Log.info("Loaded user code " + _userCode.name);

        if (_userCode != null && _gameObj != null) {
            launchUserCode();
        }
    }

    /**
     * Called once the game object and the user code are available.
     */
    protected function launchUserCode () :void
    {
        _userInstance = new _userCode();
    }

    protected var _subscriber :SafeSubscriber;
    protected var _ctx :WhirledBureauContext;
    protected var _gameObj :WhirledGameObject;
    protected var _userCode :Class;
    protected var _userInstance :Object;
}

}
