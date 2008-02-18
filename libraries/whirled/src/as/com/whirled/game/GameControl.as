//
// $Id$

package com.whirled.game {

import flash.display.DisplayObject;

import flash.errors.IllegalOperationError;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

import flash.geom.Point;

/**
 * Dispatched when the game client is unloaded and you should clean up any Timers or
 * other bits left hanging.
 *
 * @eventType flash.events.Event.UNLOAD
 */
[Event(name="unload", type="flash.events.Event")]

/**
 * Used to coordinate game state and control your multiplayer game.
 * <br><br>
 * <b>Note:</b> Check out the <a href="/code/GameControl.html" target="_top">Easy
 *   GameControl Index</a>.
 * <br><br>
 *
 * Typically, you create this in your top-level MovieClip/Sprite:
 * <code><pre>
 * public class MyGame extends Sprite
 * {
 *     public var ctrl :GameControl;
 *
 *     // Constructor
 *     public function MyGame ()
 *     {
 *          ctrl = new GameControl(this);
 *          ...
 * </pre></code>
 */
public class GameControl extends AbstractControl
{
    /**
     * Creates a GameControl that connects to the Whirled game system.
     *
     * @param disp the display object that is the game's UI.
     * @param autoReady if true, the game will automatically be started when initialization is
     * complete, if false, the game will not start until all clients call playerReady().
     *
     * @see com.whirled.game.GameSubControl#playerReady()
     */
    public function GameControl (disp :DisplayObject, autoReady :Boolean = true)
    {
        // create all our sub-controls
        _subControls.push(
            _localCtrl = new LocalSubControl(this),
            _netCtrl = new NetSubControl(this),
            _playerCtrl = new PlayerSubControl(this),
            _gameCtrl = new GameSubControl(this),
            _servicesCtrl = new ServicesSubControl(this)
        );

        var event :DynEvent = new DynEvent();
        var ourProps :Object = new Object();
        populateProperties(ourProps);
        ourProps["autoReady_v1"] = autoReady;
        event.userProps = ourProps;
        disp.root.loaderInfo.sharedEvents.dispatchEvent(event);
        if ("ezProps" in event) {
            setHostProps(event.ezProps);
        }

        // set up our focusing click handler
        disp.root.addEventListener(MouseEvent.CLICK, handleRootClick);

        // set up the unload event to propagate
        disp.root.loaderInfo.addEventListener(Event.UNLOAD, dispatch);
    }

    /**
     * @inheritDoc
     */
    override public function isConnected () :Boolean
    {
        return _connected;
    }

    /**
     * Access the 'local' services.
     */
    public function get local () :LocalSubControl
    {
        return _localCtrl;
    }

    /**
     * Access the 'net' services.
     */
    public function get net () :NetSubControl
    {
        return _netCtrl;
    }

    /**
     * Access the 'player' services.
     */
    public function get player () :PlayerSubControl
    {
        return _playerCtrl;
    }

    /**
     * Access the 'game' services.
     */
    public function get game () :GameSubControl
    {
        return _gameCtrl;
    }

    /**
     * Access the 'services' services.
     */
    public function get services () :ServicesSubControl
    {
        return _servicesCtrl;
    }

    /**
     * Populate any properties or functions we want to expose to the other side of the whirled
     * security boundary.
     * @private
     */
    override protected function populateProperties (o :Object) :void
    {
        super.populateProperties(o);

        o["connectionClosed_v1"] = connectionClosed_v1;

        for each (var ctrl :AbstractSubControl in _subControls) {
            ctrl.populatePropertiesFriend(o);
        }
    }

    /**
     * Sets the properties we received from the host framework on the other side of the security
     * boundary.
     * @private
     */
    override protected function setHostProps (o :Object) :void
    {
        super.setHostProps(o);

        // see if we're connected
        _connected = (o.gameData != null);

        for each (var ctrl :AbstractSubControl in _subControls) {
            ctrl.setHostPropsFriend(o);
        }

        // and assign our functions
        _funcs = o;
    }

    /**
     * @private
     */
    override protected function callHostCode (name :String, ... args) :*
    {
        if (_funcs != null) {
            try {
                var func :Function = (_funcs[name] as Function);
                if (func != null) {
                    return func.apply(null, args);
                }
            } catch (err :Error) {
                trace(err.getStackTrace());
                trace("--");
                throw new Error("Unable to call host code: " + err.message);
            }

        } else {
            // if _funcs is null, this will almost certainly throw an error..
            checkIsConnected();
        }
    }

    /**
     * Internal method that is called whenever the mouse clicks our root.
     * @private
     */
    protected function handleRootClick (evt :MouseEvent) :void
    {
        if (!isConnected()) {
            return;
        }
        try {
            if (evt.target.stage == null || evt.target.stage.focus != null) {
                return;
            }
        } catch (err :SecurityError) {
        }
        callHostCode("focusContainer_v1");
    }

    /**
     * Private method called when the backend disconnects from us.
     */
    private function connectionClosed_v1 () :void
    {
        _connected = false;
    }

    /** Are we connected? @private */
    protected var _connected :Boolean;

    /** Contains functions exposed to us from the game host. @private */
    protected var _funcs :Object;

    /** Holds all our sub-controls. @private */
    protected var _subControls :Array = [];

    /** The local sub-control. @private */
    protected var _localCtrl :LocalSubControl;

    /** The net sub-control. @private */
    protected var _netCtrl :NetSubControl;

    /** The player sub-control. @private */
    protected var _playerCtrl :PlayerSubControl;

    /** The game sub-control. @private */
    protected var _gameCtrl :GameSubControl;

    /** The services sub-control. @private */
    protected var _servicesCtrl :ServicesSubControl;
}
}

import flash.events.Event;

dynamic class DynEvent extends Event
{
    public function DynEvent ()
    {
        super("ezgameQuery", true, false);
    }

    override public function clone () :Event
    {
        return new DynEvent();
    }
}
