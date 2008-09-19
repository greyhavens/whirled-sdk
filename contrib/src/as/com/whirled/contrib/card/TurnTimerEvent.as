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

import flash.events.Event;

public class TurnTimerEvent extends Event
{
    /** Event type for when the timer has just kicked off. For this event type the time property
     *  is the amount of time expected to pass before the expiry event. The player property refers
     *  to the player being timed. */
    public static const STARTED :String = "turntimer.started";

    /** Event type for when a turn has expired. For this event type, the time property is not used.
     *  The player property refers to the player whose turn has expired. */
    public static const EXPIRED :String = "turntimer.expired";

    public function TurnTimerEvent (type :String, player :int, time :Number=0)
    {
        super(type);
        _player = player;
        _time = time;
    }

    /** @inheritDoc */
    // from flash.events.Event
    override public function clone () :Event
    {
        return new TurnTimerEvent(type, _player, _time);
    }

    /** @inheritDoc */
    // from Object
    override public function toString () :String
    {
        return formatToString("TurnTimerEvent", "type", "bubbles", "cancelable", 
            "player", "time");
    }

    /** Access the player whose turn is being timed or expiring. */
    public function get player () :int
    {
        return _player;
    }

    /** Access the time remaining for the turn. */
    public function get time () :Number
    {
        return _time;
    }

    protected var _player :int;
    protected var _time :Number;
}

}
