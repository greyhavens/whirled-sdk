//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled {

import flash.display.DisplayObject;

/**
 * Dispatched when a game-global state property has changed.
 * 
 * @eventType com.whirled.PropertyChangedEvent.PROPERTY_CHANGED
 */
[Event(name="propertyChanged", type="com.whirled.PropertyChangedEvent")]

/**
 * Dispatched when a player-local state property has changed.
 * 
 * @eventType com.whirled.PlayerPropertyChangedEvent.PLAYER_PROPERTY_CHANGED
 */
[Event(name="playerPropertyChanged", type="com.whirled.PlayerPropertyChangedEvent")]

/**
 * This file should be included by AVR games so that they can communicate
 * with the whirled.
 *
 * AVRGame means: Alternate Virtual Reality Game, and refers to games
 * played within the whirled environment.
 */
public class AVRGameControl extends WhirledControl
{
    /**
     * Create a world game interface. The display object is your world game.
     */
    public function AVRGameControl (disp :DisplayObject)
    {
        super(disp);
    }

    public function getProperty (key :String) :Object
    {
        return callHostCode("getProperty_v1", key);
    }

    public function setProperty (key :String, value :Object, persistent :Boolean) :Boolean
    {
        return callHostCode("setProperty_v1", key, value, persistent);
    }

    public function getPlayerProperty (key :String) :Object
    {
        return callHostCode("getPlayerProperty_v1", key);
    }

    public function setPlayerProperty (key :String, value :Object, persistent :Boolean) :Boolean
    {
        return callHostCode("setPlayerProperty_v1", key, value, persistent);
    }

    override protected function isAbstract () :Boolean
    {
        return false;
    }

    // from EZGameControl
    override protected function populateProperties (o :Object) :void
    {
        super.populateProperties(o);

        o["stateChanged_v1"] = stateChanged_v1;
        o["playerStateChanged_v1"] = playerStateChanged_v1;
    }

    /**
     * Called when a game-global state property has changed.
     */
    protected function stateChanged_v1 (key :String, value :Object) :void
    {
        dispatchEvent(new PropertyChangedEvent(key, value));
    }

    /**
     * Called when a player-local state property has changed.
     */
    protected function playerStateChanged_v1 (key :String, value :Object) :void
    {
        dispatchEvent(new PlayerPropertyChangedEvent(key, value));
    }
}
}
