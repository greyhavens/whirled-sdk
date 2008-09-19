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
import flash.events.EventDispatcher;

import flash.utils.getTimer; // function import

import com.whirled.ControlEvent;
import com.whirled.FurniControl;

import com.threerings.util.ValueEvent;

/**
 * The state updated event. Dispatched when a new state is set by another client.
 * @eventType ForkingToyState.STATE_UPDATED
 */
[Event(name="stateUpdated", type="flash.events.Event")]

/**
 * ForkingToyState manages the state of a toy such that more than one person can play with
 * it simultaneously. This is best done for a puzzle or toy that will be manipulated by
 * users through many possible states. This class allows a new entrant in the room to see
 * that someone is manipulating the toy, but the new entrant does not need to grab a lock or
 * wait for the toy to be free, they can start playing, and they will fork the state.
 */
// TODO:
// - an option to specifically save usernames in memory so they can be retrieved even
//   when a user is no longer around.
public class ForkingToyState extends EventDispatcher
{
    /** Event type constant. */
    public static const STATE_UPDATED :String = "stateUpdated";

    /**
     * ToyState constructor.
     * 
     * @param deleteCount how many personalized states to save before some are deleted.
     */
    public function ForkingToyState (ctrl :FurniControl,
        nonOwnersCanSave :Boolean = true, idleOutTimer :int = 30, deleteCount :int = 7)
    {
        if (ctrl.isConnected()) {
            _ctrl = ctrl;
            _nonOwnersCanSave = nonOwnersCanSave;

            _ctrl.addEventListener(ControlEvent.MEMORY_CHANGED, handleMemoryChanged);

            _myKey = STATE_PREFIX + _ctrl.getInstanceId();
            findFollowState(deleteCount);
        }

        _idleDelay = idleOutTimer * 1000;
    }

    /**
     * Get the state, or null if it's not set.
     */
    public function getState () :Object
    {
        return _state;
    }

    /**
     * Get the username of the player that set the current state, or null if unknown.
     */
    public function getUsernameOfState () :String
    {
        if (_ctrl != null && _followKey != null) {
            var instanceId :int = int(_followKey.substring(STATE_PREFIX.length));
            return _ctrl.getViewerName(instanceId);
        }

        return null;
    }

    /**
     * Set the state. Ignores any states set by other clients.
     */
    public function setState (state :Object) :void
    {
        _state = state;
        _seqId++;
        _followKey = _myKey;
        setTimeout();
        if (isSaving()) {
            _ctrl.setMemory(_myKey, [ _seqId, state ]);
        }
    }

    /**
     * Completely reset the state.
     */
    public function resetState () :void
    {
        _state = null;
        _seqId = 0;
        _followKey = RESET_KEY;
        setTimeout();
        if (isSaving()) {
            for (var key :String in _ctrl.getMemories()) {
                if (STATE_KEY.test(key)) {
                    _ctrl.setMemory(key, null); // kaboom!
                }
            }
            _ctrl.setMemory(RESET_KEY, [ 0, null ]);
        }
    }

    /**
     * Are we saving the state changes that the local user is making? Can we?
     * Should we?
     */
    protected function isSaving () :Boolean
    {
        return (_ctrl != null && (_nonOwnersCanSave || _ctrl.canEditRoom()));
    }

    protected function setTimeout () :void
    {
        _timeout = getTimer() + _idleDelay;
    }

    protected function handleMemoryChanged (event :ControlEvent) :void
    {
        var key :String = event.name;
        if (!STATE_KEY.test(key)) {
            return; // none of our business..
        }

        var incoming :Array = event.value as Array;
        // ignore state clears and our own state events
        if (incoming == null || key == _myKey) {
            return;
        }

        if (key == RESET_KEY) {
            // clear our follow key, in case it recently updated
            if (_followKey != null) {
                if (_followKey != RESET_KEY) {
                    _seqId = 0;
                    _state = null;
                    dispatchEvent(new Event(STATE_UPDATED));
                }
                _ctrl.setMemory(_followKey, null);
                _followKey = null;
                _timeout = 0;
            }
            return;
        }

        // follow a new key if it's time
        if (key != _followKey) {
            if (getTimer() < _timeout) {
                return; // it's not time yet
            }
            _followKey = key;
        }

        setTimeout();
        _seqId = int(incoming[0]);
        _state = incoming[1];
        dispatchEvent(new Event(STATE_UPDATED));
    }

    protected function findFollowState (deleteCount :int) :void
    {
        var highId :int = int.MIN_VALUE;
        var lowId :int = int.MAX_VALUE;
        var high :Object;
        var highKey :String;
        var lowKey :String;
        var count :int = 0;
        var memories :Object = _ctrl.getMemories();
        for (var key :String in memories) {
            if (STATE_KEY.test(key)) {
                count++;
                var mem :Array = memories[key] as Array;
                var seqId :int = int(mem[0]);
                if (seqId > highId) {
                    if (highId == int.MIN_VALUE) {
                        lowId = seqId;
                        lowKey = key; // it's also the low if we never see anything lower
                    }
                    highId = seqId;
                    highKey = key;
                    high = mem[1];

                } else if (seqId < lowId) {
                    lowId = seqId;
                    lowKey = key;
                }
            }
        }

        if (count >= deleteCount) {
            _ctrl.setMemory(lowKey, null);
        }

        _followKey = highKey;
        setTimeout();
        _state = high;
        _seqId = highId;
    }

    protected static const STATE_PREFIX :String = "_s#";

    protected static const STATE_KEY :RegExp = /^_s\#\d+$/;

    protected static const RESET_KEY :String = STATE_PREFIX + "0";

    protected var _state :Object;

    protected var _seqId :int;

    protected var _ctrl :FurniControl;

    protected var _nonOwnersCanSave :Boolean;

    protected var _idleDelay :int;

    protected var _timeout :Number = 0;

    protected var _followKey :String;

    protected var _myKey :String;
}
}
