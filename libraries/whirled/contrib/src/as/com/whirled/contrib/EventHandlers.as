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
public class EventHandlers
{
    /**
     * Adds the specified listener to the specified dispatcher for the specified event.
     */
    public static function registerEventListener (dispatcher :IEventDispatcher, event :String,
        listener :Function) :void
    {
        dispatcher.addEventListener(event, listener);
        _eventHandlers.push({dispatcher: dispatcher, event: event, func: listener});
    }

    /**
     * Removes the specified listener from the specified dispatcher for the specified event.
     */
    public static function unregisterEventListener (dispatcher :IEventDispatcher, event :String,
        listener :Function) :void
    {
        dispatcher.removeEventListener(event, listener);
        for (var ii :int = 0; ii < _eventHandlers.length; ii++) {
            if (dispatcher == _eventHandlers[ii].dispatcher && event == _eventHandlers[ii].event &&
                listener == _eventHandlers[ii].func) {
                _eventHandlers.splice(ii, 1);
                break;
            }
        }
    }

    /**
     * Registers the freeAllHandlers() method to be called upon Event.UNLOAD on the supplied
     * event dispatcher.
     */
    public static function registerUnload (dispatcher :IEventDispatcher) :void
    {
        registerEventListener(dispatcher, Event.UNLOAD, freeAllHandlers);
    }

    /**
     * Free all handlers that have been added via this registerEventListener() and have not been
     * freed already via unregisterEventListener()
     */
    public static function freeAllHandlers (...ignored) :void
    {
        for each (var handler :Object in _eventHandlers) {
            handler.dispatcher.removeEventListener(handler.event, handler.func);
        }
        _eventHandlers = [];
    }

    protected static var _eventHandlers :Array = [];
}
}
