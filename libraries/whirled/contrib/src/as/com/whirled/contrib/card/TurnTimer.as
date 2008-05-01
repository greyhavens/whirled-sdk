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
// $Id: SimObject.as 4196 2008-04-29 19:16:55Z tim $

package com.whirled.contrib.card {

import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.utils.Timer;

import com.whirled.game.GameControl;
import com.whirled.game.StateChangedEvent;
import com.whirled.game.MessageReceivedEvent;

/** Regulates the length of time consumed by a player making a move. Basically just listens for 
 *  turn changes and dispatches events when a certain amount of time has passed. Reduces the amount
 *  of time allowed for a player's turn each time that player misses, reducing the annoyance of 
 *  other players if someone goes AFK or offline or just isn't fast enough. The base turn time is
 *  restored within a small number of turns if the player returns to making moves. */
public class TurnTimer extends EventDispatcher
{
    /** Creates a new turn timer for a given game control and table. 
     *  @param gameCtrl the game control
     *  @param table the table where turns are being timed
     *  @param bids the bids (needed because more time is allowed for bidding) */
    public function TurnTimer (
        gameCtrl :GameControl, 
        table :Table)
    {
        _gameCtrl = gameCtrl;
        _table = table;
        
        var tracker :Array = new Array(table.numPlayers);
        for (var i :int = 0; i < tracker.length; ++i) {
            tracker[i] = 0;
        }
        _gameCtrl.net.set(EXPIRY_TRACKER, tracker);

        gameCtrl.game.addEventListener(
            StateChangedEvent.TURN_CHANGED, 
            handleTurnChanged);
        _gameCtrl.net.addEventListener(
            MessageReceivedEvent.MESSAGE_RECEIVED,
            handleMessage);
        _timer.addEventListener(TimerEvent.TIMER, timerListener);
    }

    /** Access a function to be called for outputting messages about turn timing. The function
     *  must take a single string argument and return void. If set to null, no debug output
     *  will occur. */
    public function get debug () :Function
    {
        return _debug;
    }

    /** Access a function to be called for outputting messages about turn timing. The function
     *  must take a single string argument and return void. If set to null, no debug output
     *  will occur. */
    public function set debug (fn :Function) :void
    {
        _debug = fn;
    }

    /** Access the amount of time allowed for playing a card. */
    public function get playTime () :Number
    {
        return _playTime;
    }

    /** Access the amount of time allowed for playing a card. */
    public function set playTime (time :Number) :void
    {
        _playTime = time;
    }

    /** Disable the turn timer. For debugging specific game play situations. */
    public function disable () :void
    {
        _enabled = false;
    }

    /** Restart the timer for the current turnholder. Used if there is a multi-stage turn where 
     *  the turn holder does not change. */
    public function restart () :void
    {
        if (!_gameCtrl.game.amInControl()) {
            if (_debug != null) {
                _debug("TurnTimer.restart called with no effect");
            }
            return;
        }

        if (!_enabled) {
            return;
        }

        if (turnHolder != 0) {
            var time :Number = getCurrentTurnTimeBase(turnHolder);
            var seat :int = _table.getAbsoluteFromId(turnHolder);

            // diminish by the number of expiries in past turns
            var missedTurns :int = countExpiries(seat);
            missedTurns = Math.min(HISTORY_EFFECT.length - 1, missedTurns);
            time *= HISTORY_EFFECT[missedTurns];

            _gameCtrl.net.sendMessage(MSG_START, [turnHolder, time]);
            _lastTurnHolder = turnHolder;
        }
    }

    /** Get the base amount of time that should be allowed for the current turn. The time is 
     *  automatically diminished proprtionally to the number of turns the player has missed.
     *  Subclasses should override to accout for different game play situations. */
    protected function getCurrentTurnTimeBase (turnHolder :int) :Number
    {
        return _playTime;
    }

    protected function handleTurnChanged (event :StateChangedEvent) :void
    {
        if (!_gameCtrl.game.amInControl() || !_enabled) {
            return;
        }

        if (_lastTurnHolder != 0) {
            addHistory(_lastTurnHolder, false, 2);
            _lastTurnHolder = 0;
            _timer.stop();
        }

        restart();
    }

    protected function handleMessage (event :MessageReceivedEvent) :void
    {
        var player :int;

        if (event.name == MSG_START) {
            player = (event.value as Array)[0] as int;
            var time :Number = (event.value as Array)[1] as Number;

            if (turnHolder == player) {
                if (_gameCtrl.game.amInControl()) {
                    _timer.delay = time * 1000;
                    _timer.reset();
                    _timer.start();
                }
                dispatchEvent(new TurnTimerEvent(
                    TurnTimerEvent.STARTED, player, time));
                if (_debug != null) {
                    _debug("Turn timer started for " + 
                        _table.getNameFromId(player) + ", time " + time);
                }
            }
        }
        else if (event.name == MSG_EXPIRED) {
            player = event.value as int;
            if (turnHolder == player) {
                if (_gameCtrl.game.amInControl()) {
                    addHistory(player, true, 1);
                    _lastTurnHolder = 0;
                }
                dispatchEvent(new TurnTimerEvent(
                    TurnTimerEvent.EXPIRED, player, time));
                if (_debug != null) {
                    _debug("Turn timer expired for " + 
                        _table.getNameFromId(player));
                }
            }
        }
    }

    protected function get turnHolder () :int
    {
        return _gameCtrl.game.getTurnHolderId();
    }

    protected function timerListener (event :TimerEvent) :void
    {
        if (_gameCtrl.game.amInControl()) {
            if (_lastTurnHolder == turnHolder) {
                _gameCtrl.net.sendMessage(MSG_EXPIRED, _lastTurnHolder);
            }
            else {
                if (_debug != null) {
                    _debug("Last turn holder was " + _lastTurnHolder + 
                        " but current is " + turnHolder);
                }
            }
        }
    }

    protected function countExpiries (seat :int) :int
    {
        var tracker :Array = _gameCtrl.net.get(EXPIRY_TRACKER) as Array;
        var counter :int = tracker[seat] as int;
        var count :int = 0;
        while (counter != 0) {
            count += (counter & 1);
            counter >>= 1;
        }
        return count;
    }

    protected function addHistory (
        turnHolder :int, 
        expired :Boolean, 
        count :int) :void
    {
        var seat :int = _table.getAbsoluteFromId(turnHolder);
        var tracker :Array = _gameCtrl.net.get(EXPIRY_TRACKER) as Array;

        var history :int = tracker[seat];
        while (count-- > 0) {
            history <<= 1;
            if (expired) {
                history |= 1;
            }
            history &= HISTORY_MASK;
        }

        _gameCtrl.net.setAt(EXPIRY_TRACKER, seat, history);

        if (_debug != null) {
            _debug("Player " + _table.getNameFromId(turnHolder) + 
                " now has " + countExpiries(seat) + " expiries");
        }
    }

    protected var _gameCtrl :GameControl;
    protected var _table :Table;
    protected var _timer :Timer = new Timer(0, 1);
    protected var _playTime :Number = 10;
    protected var _lastTurnHolder :int = 0;
    protected var _enabled :Boolean = true;
    protected var _debug :Function;

    protected static const EXPIRY_TRACKER :String = "turntimer.expirytracker";
    protected static const MSG_START :String = "turntimer.start";
    protected static const MSG_EXPIRED :String = "turntimer.stop";
    protected static const HISTORY_SIZE :int = 4;
    protected static const HISTORY_MASK :int = 0x0000000F;
    protected static const HISTORY_EFFECT :Array = [1.0, 1.0, 0.5, 0.25, 0.125];
}

}
