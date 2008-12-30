//
// $Id$

package com.whirled {

import flash.display.DisplayObject;

import flash.errors.IllegalOperationError;

import flash.events.Event;
import flash.events.EventDispatcher;

/**
 * Event.UNLOAD
 * Dispatched when the SWF using this control has been unloaded.
 * You should clean-up any resources that would otherwise stick around, like stopping any
 * Timers, cancelling any sound streams, etc.
 *
 * @eventType flash.events.Event.UNLOAD
 */
[Event(name="unload", type="flash.events.Event")]

/**
 * The abstract base class for all controls and subcontrols.
 */
public class AbstractControl extends EventDispatcher
{
    /**
     * @param disp the display object on the stage
     * @param initialUserProps any userProps that should be configured even prior to setUserProps.
     * @private
     */
    public function AbstractControl (disp :DisplayObject, initialUserProps :Object = null)
    {
        // always create our sub-controls
        _subControls = createSubControls();

        // stop here if we ourselves are a sub-control
        if (this is AbstractSubControl) {
            return;
        }

        if (disp.root == null) {
            throw new Error("Display object used to instantiate a control must be on the stage");
        }

        // set up the unload event to propagate
        disp.root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload, false, 0, true);

        // do the connect!
        var userProps :Object = (initialUserProps != null) ? initialUserProps : new Object();
        setUserProps(userProps);
        var event :ConnectEvent = new ConnectEvent();
        event.props.userProps = userProps;
        disp.root.loaderInfo.sharedEvents.dispatchEvent(event);
        if (Boolean(event.props.alreadyConnected)) {
            throw new Error("You've already set up a Control instance. There should only be one.");
        }
        var hostProps :Object = event.props.hostProps;
        if (hostProps != null) {
            gotHostProps(hostProps);
        }
    }

    /**
     * Registers an event listener.
     */
    override public function addEventListener (
        type :String, listener :Function, useCapture :Boolean = false, priority :int = 0,
        useWeakReference :Boolean = false) :void
    {
        super.addEventListener(type, listener, useCapture, priority, useWeakReference);
    }

    /**
     * Unregisters an event listener.
     */
    override public function removeEventListener (
        type :String, listener :Function, useCapture :Boolean = false) :void
    {
        super.removeEventListener(type, listener, useCapture);
    }

    /**
     * Are we connected and running inside the whirled environment, or has someone just
     * loaded up our SWF by itself?
     */
    public function isConnected () :Boolean
    {
        return (_funcs != null);
    }

    /**
     * Execute the specified function as a batch of commands that will be sent to the server
     * together.  Messages can be sent no faster than a rate of 10 per second.  Using doBatch groups
     * a number of set or sendMessage operations so that they are treated as a single unit towards
     * this limit. For best performance, it should be used whenever a number of values are being set
     * at once.
     *
     * @example
     * <listing version="3.0">
     * _ctrl.doBatch(function () :void {
     *     _ctrl.net.set("board", new Array(100));
     *     _ctrl.net.set("scores", new Dictionary());
     *     _ctrl.net.set("captures", 0);
     * });
     * </listing>
     *
     * Note that it guarantees that those events get processed by the server as a unit, but
     * the results will not come back as a unit. So, for instance, when you receive the
     * PropertyChangedEvent for "board", checking the value of "scores" will still return
     * the old value.
     */
    public function doBatch (fn :Function, ... args) :void
    {
        callHostCode("startTransaction");
        try {
            fn.apply(null, args);
        } finally {
            callHostCode("commitTransaction");
        }
    }

    /**
     * Handle any shutdown required.
     * @private
     */
    protected function handleUnload (event :Event) :void
    {
        // redispatch the unload event to listeners of this object
        dispatch(event);
    }

    /**
     * Populate any properties or functions we want to expose to the host code.
     * @private
     */
    protected function setUserProps (o :Object) :void
    {
        for each (var ctrl :AbstractSubControl in _subControls) {
            ctrl.setUserPropsFriend(o);
        }
    }

    /**
     * Grab any properties needed from our host code.
     * @private
     */
    protected function gotHostProps (o :Object) :void
    {
        // by default, we just use these props as our _funcs
        _funcs = o;

        for each (var ctrl :AbstractSubControl in _subControls) {
            ctrl.gotHostPropsFriend(o);
        }
    }

    /**
     * Your own events may not be dispatched here.
     * @private
     */
    override public function dispatchEvent (event :Event) :Boolean
    {
        // Ideally we want to not be an EventDispatcher so that people
        // won't try to do this on us, but if we do that, then some other
        // object will be the target during dispatch, and that's weird.
        throw new IllegalOperationError();
    }

    /**
     * Secret function to dispatch events.
     * @private
     */
    protected function dispatch (event :Event) :void
    {
        try {
            super.dispatchEvent(event);
        } catch (err :Error) {
            // AFAIK, this will never happen: dispatchEvent catches and copes with all exceptions.
            trace("Error dispatching event to user code.");
            trace(err.getStackTrace());
        }
    }

    /**
     * Call a method exposed by the host code.
     * @private
     */
    protected function callHostCode (name :String, ... args) :*
    {
        if (_funcs != null) {
            try {
                var func :Function = (_funcs[name] as Function);
                if (func == null) {
                    trace("Host code \"" + name + "\" not found!");
                } else {
                    return func.apply(null, args);
                }
            } catch (err :Error) {
                trace("Error! Unable to call host code. Maybe we've been shut down? " +
                    "You should fix this. [msg=" + err.message +
                    ", trace=" + err.getStackTrace() + "].");
            }

        } else {
            checkIsConnected();
        }

        // if we get here then either _funcs is not null, but our function is not there, or
        // _funcs is null but checkIsConnected() thinks everything is ok.
        return undefined;
    }

    /**
     * Exposed to sub controls.
     * @private
     */
    internal function callHostCodeFriend (name :String, args :Array) :*
    {
        args.unshift(name);
        return callHostCode.apply(this, args);
    }

    /**
     * Helper method to throw an error if we're not connected.
     * @private
     */
    protected function checkIsConnected () :void
    {
        if (!isConnected()) {
            throw new IllegalOperationError(
                "The control is not connected to the host framework, please check isConnected(). " +
                "If false, your SWF is being viewed standalone and should adjust.");
        }
    }

    /**
     * Override and return any custom sub-controls.
     * @private
     */
    protected function createSubControls () :Array
    {
        return null;
    }

    /** The functions supplied by the host. @private */
    protected var _funcs :Object;

    /** Any sub-controls we may have. @private */
    protected var _subControls :Array;
}
}

import flash.events.Event;

/**
 * A special event we can use to pass info back to whirled.
 */
class ConnectEvent extends Event
{
    /** A place to store all properties, rather than make this a dynamic class. */
    public var props :Object;

    /** Construct a new ConnectEvent. */
    public function ConnectEvent (propsObj :Object = null)
    {
        super("controlConnect", true, false);
        props = propsObj || {};
    }

    override public function clone () :Event
    {
        // The cloned object needs to accessing and modifying the same props.
        return new ConnectEvent(props);
    }
}
