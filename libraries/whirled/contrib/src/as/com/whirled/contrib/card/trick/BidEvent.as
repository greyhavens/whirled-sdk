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

package com.whirled.contrib.card.trick {

import flash.events.Event;

/** Event for something that happens to a bid. */
public class BidEvent extends Event
{
    /** Event type for when the bids are reset. For this event type, the player and value 
     *  properties are not used. */
    public static const RESET :String = "bid.reset";

    /** Event type for when a bid is requested. For this event type, the player is set to the id 
     *  of the player who is requested to bid and the value is set to the maximum amount. */
    public static const REQUESTED :String = "bid.requested";

    /** Event type for when a bid is selected. For this event type, the value is set to the 
     *  amount selected and the player is set to the id of the player who bid. */
    public static const SELECTED :String = "bid.selected";

    /** Event type for when a bid is placed. For this event type, the value is set to the amount 
     *  bid and the player is set to the id of the player who bid. */
    public static const PLACED :String = "bid.placed";

    /** Event type for when all bids are in. For this event type, the player and value properties 
     *  are not used. */
    public static const COMPLETED :String = "bid.completed";

    /** Placeholder function for Bids subclasses to add new event types. */
    public static function newEventType (type :String) :String
    {
        return type;
    }

    /** Create a new bid event. */
    public function BidEvent (type :String, player :int=0, value :int=-1)
    {
        super(type);
        _player = player;
        _value = value;
    }

    /** @inheritDoc */
    // from flash.events.Event
    public override function clone () :Event
    {
        return new BidEvent(type, player, value);
    }

    /** @inheritDoc */
    // from Object
    public override function toString () :String
    {
        return formatToString("BidEvent", "type", "bubbles", "cancelable", 
            "value", "player");
    }

    /** Access the value of the bid, if appropriate. */
    public function get value () :int
    {
        return _value;
    }

    /** Access the id of the player who has placed a bid, if any. */
    public function get player () :int
    {
        return _player;
    }

    protected var _player :int;
    protected var _value :int;
}

}
