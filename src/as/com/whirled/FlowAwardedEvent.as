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
     * the player has earned flow.
     *
     * @eventType flowAwarded
     */
    public static const FLOW_AWARDED :String = "flowAwarded";

    /**
     * Returns the amount of flow awarded to the player.
     */
    public function get amount () :int
    {
        return _amount;
    }

    /**
     * Returns the % of scores lower than the player's reported score, or -1 if no score was
     * reported.
     */
    public function get percentile () :int
    {
        return _percentile;
    }

    /**
     * Creates a new event.
     */
    public function FlowAwardedEvent (amount :int, percentile :int)
    {
        super(FLOW_AWARDED);
        _amount = amount;
        _percentile = percentile;
    }

    // from Event
    override public function clone () :Event
    {
        return new FlowAwardedEvent(_amount, _percentile);
    }

    // from Event
    override public function toString () :String
    {
        return "FlowAwardedEvent [type=" + type + ", amount=" + _amount + "]";
    }

    /** The amount of flow awarded to the player. */
    protected var _amount :int;

    /** The % of scores lower than the player's reported score, or -1 if no score was reported. */
    protected var _percentile :int;
}
}
