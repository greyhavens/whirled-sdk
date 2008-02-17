//
// $Id$

package com.whirled.game {

import flash.errors.IllegalOperationError;

import flash.events.Event;
import flash.events.EventDispatcher;

/**
 * The abstract base class for Game controls and subcontrols.
 * @private
 */
public class AbstractControl extends EventDispatcher
{
    public function AbstractControl ()
    {
        if (Object(this).constructor == AbstractControl) {
            throw new IllegalOperationError("Abstract");
        }
    }

    /**
     * Are we connected and running inside the game environment, or has someone just
     * loaded up our SWF by itself?
     */
    public function isConnected () :Boolean
    {
        return false;
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
     * Populate any properties or functions we want to expose to the host code.
     * @private
     */
    protected function populateProperties (o :Object) :void
    {
        // nothing by default
    }

    /**
     * Grab any properties needed from our host code.
     * @private
     */
    protected function setHostProps (o :Object) :void
    {
        // nothing by default
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
            trace("Error dispatching event to user game.");
            trace(err.getStackTrace());
        }
    }

    /**
     * Call a method exposed by the host code.
     * @private
     */
    protected function callHostCode (name :String, ... args) :*
    {
        return undefined; // no-op by default
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
                "The game is not connected to the host framework, please check isConnected(). " +
                "If false, your game is being viewed standalone and should adjust.");
        }
    }
}
}
