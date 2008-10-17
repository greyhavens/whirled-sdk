// Whirled contrib library - tools for developing whirled games
// http://www.whirled.com/code/contrib/asdocs
//
// This library is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library.  If not, see <http://www.gnu.org/licenses/>.
//
// Copyright 2008 Three Rings Design
//
// $Id$

package com.whirled.contrib {

import flash.events.Event;
import flash.events.IEventDispatcher;

/**
 * A class for keeping track of event listeners and freeing them all at a given time.  This is
 * useful for keeping track of your ENTER_FRAME listeners, and releasing them all on UNLOAD to
 * make sure your game/furni/avatar fully unloads at the proper time.
 */
public class EventHandlerManager
{
    /**
     * Adds the specified listener to the specified dispatcher for the specified event.
     */
    public function registerEventListener (dispatcher :IEventDispatcher, event :String,
        listener :Function, useCapture :Boolean = false, priority :int = 0,
        useWeakReference :Boolean = false) :void
    {
        dispatcher.addEventListener(event, listener, useCapture, priority, useWeakReference);
        _eventHandlers.push(new RegisteredListener(dispatcher, event, listener, useCapture));
    }

    /**
     * Removes the specified listener from the specified dispatcher for the specified event.
     */
    public function unregisterEventListener (dispatcher :IEventDispatcher, event :String,
        listener :Function, useCapture :Boolean = false) :void
    {
        dispatcher.removeEventListener(event, listener, useCapture);

        for (var ii :int = 0; ii < _eventHandlers.length; ii++) {
            var rl :RegisteredListener = _eventHandlers[ii];
            if (dispatcher == rl.dispatcher && event == rl.event &&  listener == rl.listener &&
                useCapture == rl.useCapture) {
                _eventHandlers.splice(ii, 1);
                break;
            }
        }
    }

    /**
     * Registers a zero-arg callback function that should be called once when the event fires.
     */
    public function registerOneShotCallback (dispatcher :IEventDispatcher, event :String,
        callback :Function, useCapture :Boolean = false, priority :int = 0) :void
    {
        var eventListener :Function = function (...ignored) :void {
            unregisterEventListener(dispatcher, event, eventListener, useCapture);
            callback();
        };

        registerEventListener(dispatcher, event, eventListener, useCapture, priority);
    }

    /**
     * Registers the freeAllHandlers() method to be called upon Event.UNLOAD on the supplied
     * event dispatcher.
     */
    public function registerUnload (dispatcher :IEventDispatcher) :void
    {
        registerEventListener(dispatcher, Event.UNLOAD, freeAllHandlers);
    }

    /** 
     * Will either call a given function now, or defer it based on the boolean parameter.  If the 
     * parameter is false, the function will be registered as a one-shot callback on the dispatcher
     */
    public function conditionalCall (callback :Function, callNow :Boolean, 
        dispatcher :IEventDispatcher, event :String, useCapture :Boolean = false, 
        priority :int = 0) :void
    {
        if (callNow) {
            callback();
        } else {
            registerOneShotCallback(dispatcher, event, callback, useCapture, priority);
        }
    }

    /**
     * Free all handlers that have been added via this registerEventListener() and have not been
     * freed already via unregisterEventListener()
     */
    public function freeAllHandlers (...ignored) :void
    {
        for each (var rl :RegisteredListener in _eventHandlers) {
            rl.dispatcher.removeEventListener(rl.event, rl.listener, rl.useCapture);
        }

        _eventHandlers = [];
    }

    protected var _eventHandlers :Array = [];
}

}

import flash.events.IEventDispatcher;

class RegisteredListener
{
    public var dispatcher :IEventDispatcher;
    public var event :String;
    public var listener :Function;
    public var useCapture :Boolean;

    public function RegisteredListener (dispatcher :IEventDispatcher, event :String,
        listener :Function, useCapture :Boolean)
    {
        this.dispatcher = dispatcher;
        this.event = event;
        this.listener = listener;
        this.useCapture = useCapture;
    }
}
