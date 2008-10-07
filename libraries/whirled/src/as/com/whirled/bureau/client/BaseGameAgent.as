//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.bureau.client {

import flash.utils.Timer;
import flash.events.TimerEvent;

import com.threerings.io.TypedArray;

import com.threerings.util.Log;

import com.threerings.presents.dobj.ObjectAccessError;
import com.threerings.presents.dobj.Subscriber;
import com.threerings.presents.dobj.SubscriberAdapter;

import com.threerings.presents.util.SafeSubscriber;

import com.threerings.bureau.client.Agent;

import com.threerings.crowd.data.PlaceObject;

import com.whirled.bureau.util.WhirledBureauContext;

/**
 * The container for a user's game control code. Base class to share code for server agents for
 * any kind of game.
 */
public class BaseGameAgent extends Agent
{
    public static var log :Log = Log.getLog(BaseGameAgent);

    public function BaseGameAgent (ctx :WhirledBureauContext)
    {
        _ctx = ctx; 

        _traceTimer.addEventListener(TimerEvent.TIMER, handleTimer);
    }

    // from Agent
    public override function start () :void
    {
        log.info("Starting agent", "agentObj", _agentObj);

        // subscribe to the game object
        var delegator :Subscriber = 
            new SubscriberAdapter(gameObjectAvailable, gameObjectRequestFailed);

        var gameOid :int = getGameOid();
        log.info("Subscribing to game object", "oid", gameOid);

        _subscriber = new SafeSubscriber(gameOid, delegator);
        _subscriber.subscribe(_ctx.getDObjectManager());

        // download the code
        _ctx.getUserCodeLoader().load(_agentObj.code, _agentObj.className, gotUserCode);
    }

    // from Agent
    public override function stop () :void
    {
        log.info("Stopping agent", "agentObj", _agentObj.which());

        handleTimer(null);
        _traceTimer.stop();
        _traceTimer.removeEventListener(TimerEvent.TIMER, handleTimer);
        _traceTimer = null;

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

    /**
     * Outputs a message to the user code's internal trace method. This is used to avoid
     * generating warnings and traces from backend and controller code.
     */
    public function outputToUserCode (msg :String, err :Error = null) :void
    {
        if (_userCode != null) {
            _userCode.outputTrace(msg, err);
        }
    }

    /**
     * Gets the oid of the game object so that a subscription can be established when the agent
     * starts.
     */
    protected function getGameOid () :int
    {
        throw new Error("Abstract");
    }

    /**
     * Callback for when the request to subscribe to the game object finishes and the object is 
     * available.
     */
    protected function gameObjectAvailable (gameObj :PlaceObject) :void
    {
        log.info("Subscribed to game object", "gameObj", gameObj.which());
        _gameObj = gameObj;

        // This also initializes the controller
        _controller = createController();

        if (_userCode != null && _gameObj != null) {
            launchUserCode();
        }
    }

    /**
     * Callback for when the a request to subscribe to the game object fails.
     */
    protected function gameObjectRequestFailed (oid :int, cause :ObjectAccessError) :void
    {
        log.warning("Could not subscribe to game object", "oid", oid, cause);
        _controller.agentFailed();
    }

    /**
     * Callback for when the user code is available.
     */
    protected function gotUserCode (userCode :UserCode) :void
    {
        if (userCode == null) {
            log.warning("Unable to load user code", "agentObj", _agentObj.which());
            _controller.agentFailed();
            return;
        }

        _userCode = userCode;
        log.info("Loaded agent user code", "code", _userCode, "agent", _agentObj.which());

        if (_userCode != null && _gameObj != null) {
            launchUserCode();
        }
    }

    /**
     * Called once the game object and the user code (domain) are available.
     */
    protected function launchUserCode () :void
    {
        _userCode.connect(_controller.getConnectListener(), relayTrace);
        
        if (!_controller.isConnected()) {
            log.info("Could not connect to user code", "agentObj", _agentObj.which());
            _controller.agentFailed();
            return;
        }

        _controller.agentReady();
    }

    /**
     * Called whenever a trace() is sent back to us from a usercode Domain; we batch these up and
     * relay back to the server periodically and on shutdown.
     */
    protected function relayTrace (trace :String) :void
    {
        if (_traceTimer == null) {
            log.warning("relayTrace called after agent stop", new Error());

        } else {
            _traceOutput.push(trace);
            _traceTimer.start();
        }
    }

    /**
     * Checks to see if we have some trace output to send to the server an if so, sends it.
     */
    protected function handleTimer (event :TimerEvent) :void
    {
        if (_traceOutput.length == 0) {
            _traceTimer.stop();

        } else {
            if (_gameObj != null && _gameObj.manager != null) {
                _gameObj.manager.invoke("agentTrace", _traceOutput);
            }
            _traceOutput.length = 0;
        }
    }

    /**
     * Creates and initializes the controller for this agent.
     */
    protected function createController () :GameAgentController
    {
        throw new Error("abstract");
    }

    protected var _subscriber :SafeSubscriber;
    protected var _ctx :WhirledBureauContext;
    protected var _gameObj :PlaceObject;
    protected var _userCode :UserCode;
    protected var _controller :GameAgentController;
    protected var _traceOutput :TypedArray = TypedArray.create(String);
    protected var _traceTimer :Timer = new Timer(1000);
}

}
