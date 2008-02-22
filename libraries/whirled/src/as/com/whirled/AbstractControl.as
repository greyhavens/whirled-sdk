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

        // set up the unload event to propagate
        // (Also causes a NPE as quickly as possible if disp is null or not on the stage.)
        disp.root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);

        // do the connect!
        var userProps :Object = (initialUserProps != null) ? initialUserProps : new Object();
        setUserProps(userProps);
        var event :ConnectEvent = new ConnectEvent();
        event.userProps = userProps;
        disp.root.loaderInfo.sharedEvents.dispatchEvent(event);
        var hostProps :Object = event.hostProps;
        if (hostProps != null) {
            gotHostProps(hostProps);
        }
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
     * together. This is no different from executing the commands outside of a batch, but
     * may result in better use of the network and should be used if setting a number of things
     * at once.
     *
     * Example:
     * <code>
     * _ctrl.doBatch(function () :void {
     *     _ctrl.net.set("board", new Array());
     *     _ctrl.net.set("scores", new Array());
     *     _ctrl.net.set("captures", 0);
     * });
     * </code>
     *
     * <br/><br/>
     * <b>Note</b>: This will work on any control, but currently only GameControl and its
     * sub-controls will actually do network batching.
     */
    public function doBatch (fn :Function) :void
    {
        callHostCode("startTransaction");
        try {
            fn();
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
                if (func != null) {
                    return func.apply(null, args);
                }
            } catch (err :Error) {
                trace(err.getStackTrace());
                throw new Error("Unable to call host code: " + err.message);
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

    /** Any sub-controls we may have. If you need to have subcontrols on any
     * control, set this array up before calling the super constructor. @private */
    protected var _subControls :Array;
}
}

import flash.events.Event;

/**
 * A special event we can use to pass info back to whirled.
 */
class ConnectEvent extends Event
{
    public function ConnectEvent ()
    {
        super("controlConnect", true, false);
    }

    /** Setter: hostProps */
    public function set hostProps (props :Object) :void
    {
        if (_parent != null) {
            _parent.hostProps = props;
        } else {
            _hostProps = props;
        }
    }

    /** Getter: hostProps */
    public function get hostProps () :Object
    {
        // we don't really allow this get on a child
        return _hostProps;
    }

    /** Setter: userProps */
    public function set userProps (props :Object) :void
    {
        // we don't really allow this set on a child
        _userProps = props;
    }

    /** Getter: userProps */
    public function get userProps () :Object
    {
        if (_parent != null) {
            return _parent.userProps;
        } else {
            return _userProps;
        }
    }

    override public function clone () :Event
    {
        var clone :ConnectEvent = new ConnectEvent();
        clone._parent = this;
        return clone;
    }

    protected var _parent :ConnectEvent;

    protected var _hostProps :Object;
    protected var _userProps :Object;
}
