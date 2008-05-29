//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.bureau.client {

import com.threerings.bureau.util.BureauContext;
import com.threerings.bureau.client.Agent;
import com.threerings.bureau.Log;
import com.whirled.bureau.data.GameAgentObject;
import com.threerings.presents.dobj.ObjectAccessError;
import com.threerings.presents.dobj.Subscriber;
import com.threerings.presents.dobj.SubscriberAdapter;
import com.threerings.presents.util.SafeSubscriber;
import com.whirled.game.data.WhirledGameObject;

/** The container for a user's game control code. */
public class GameAgent extends Agent
{
    public function GameAgent (ctx :BureauContext)
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
    }

    // from Agent
    public override function stop () :void
    {
        Log.info("Stopping agent " + _agentObj);
        _subscriber.unsubscribe(_ctx.getDObjectManager());
        _subscriber = null;
        _gameObj = null;
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
    }

    /**
     * Callback for when the a request to subscribe to the game object fails.
     */
    protected function requestFailed (oid :int, cause :ObjectAccessError) :void
    {
        Log.warning("Could not subscribe to game object [oid=" + oid + "]");
        Log.logStackTrace(cause);
    }

    protected var _subscriber :SafeSubscriber;
    protected var _ctx :BureauContext;
    protected var _gameObj :WhirledGameObject;
}

}
