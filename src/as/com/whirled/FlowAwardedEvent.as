//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled {

import flash.events.Event;

/**
 * Dispatched to let a game know when the player has been awarded flow.
 */
public class FlowAwardedEvent extends Event
{
    /**
     * An event type dispatched at the end of a game (before GAME_ENDED) to inform the game that
     * the local player has earned flow.
     *
     * @eventType flowAwarded
     */
    public static const FLOW_AWARDED :String = "flowAwarded";

    /**
     * Returns the amount of flow awarded to the player.
     */
    public function get amount () :Object
    {
        return _amount;
    }

    /**
     * Creates a new event.
     */
    public function FlowAwardedEvent (type :String, amount :int)
    {
        super(type);
        _amount = amount;
    }

    // from Event
    override public function clone () :Event
    {
        return new FlowAwardedEvent(type, _amount);
    }

    // from Event
    override public function toString () :String
    {
        return "FlowAwardedEvent [type=" + type + ", amount=" + _amount + "]";
    }

    /** The amount of flow awarded to the local player. */
    protected var _amount :int;
}
}
