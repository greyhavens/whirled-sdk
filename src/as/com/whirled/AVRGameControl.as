//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled {

import flash.display.DisplayObject;
import flash.geom.Rectangle;

/**
 * Dispatched when a game-global state property has changed.
 * 
 * @eventType com.whirled.AVRGameControlEvent.PROPERTY_CHANGED
 */
[Event(name="propertyChanged", type="com.whirled.AVRGameControlEvent")]

/**
 * Dispatched when a player-local state property has changed.
 * 
 * @eventType com.whirled.AVRGameControlEvent.PLAYER_PROPERTY_CHANGED
 */
[Event(name="playerPropertyChanged", type="com.whirled.AVRGameControlEvent")]

/**
 * Dispatched when a message has been received.
 * 
 * @eventType com.whirled.AVRGameControlEvent.MESSAGE_RECEIVED
 */
[Event(name="messageReceived", type="com.whirled.AVRGameControlEvent")]

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

    /**
     * Returns the bounds of the "stage" on which the AVRG will be drawn. This is the entire
     * area the AVRG can cover and includes potential empty space to the right of the room
     * view. See <code>getRoomBounds</code>. TODO: Implement RESIZE event.
     */
    public function getStageBounds () :Rectangle
    {
        return Rectangle(callHostCode("getStageBounds_v1"));
    }

    /**
     * Returns the bounds of our current room, or null in the unlikely case that we are
     * not in a room. Note that these bounds are likely to change every time the player
     * enters a different scene. TODO: Bring back movement events.
     */
    public function getRoomBounds () :Rectangle
    {
        return Rectangle(callHostCode("getRoomBounds_v1"));
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

    public function sendMessage (key :String, value :Object, playerId :int = 0) :Boolean
    {
        return callHostCode("sendMessage_v1", key, value, playerId);
    }

    public function offerQuest (questId :String, intro :String, initialStatus :String) :Boolean
    {
        return callHostCode("offerQuest_v1", questId, intro, initialStatus);
    }

    public function updateQuest (questId :String, step :int, status :String) :Boolean
    {
        return callHostCode("updateQuest_v1", questId, step, status);
    }

    public function completeQuest (questId :String, outro :String, payout :int) :Boolean
    {
        return callHostCode("completeQuest_v1", questId, outro, payout);
    }

    public function cancelQuest (questId :String) :Boolean
    {
        return callHostCode("cancelQuest_v1", questId);
    }

    public function getActiveQuests () :Array
    {
        return callHostCode("getActiveQuests_v1");
    }

    public function deactivateGame () :Boolean
    {
        return callHostCode("deactivateGame_v1");
    }

    override protected function isAbstract () :Boolean
    {
        return false;
    }

    override protected function populateProperties (o :Object) :void
    {
        super.populateProperties(o);

        o["stateChanged_v1"] = stateChanged_v1;
        o["playerStateChanged_v1"] = playerStateChanged_v1;
        o["messageReceived_v1"] = messageReceived_v1;
        o["questStateChanged_v1"] = questStateChanged_v1;
    }

    /**
     * Helper method to dispatch an AVRGameControlEvent, but only if there is an associated
     * listener.
     */
    protected function avrgDispatch (ev :String, key :String = null, value :Object = null) :void
    {
        if (hasEventListener(ev)) {
            dispatchEvent(new AVRGameControlEvent(ev, key, value));
        }
    }

    /**
     * Called when a game-global state property has changed.
     */
    protected function stateChanged_v1 (key :String, value :Object) :void
    {
        avrgDispatch(AVRGameControlEvent.PROPERTY_CHANGED, key, value);
    }

    /**
     * Called when a player-local state property has changed.
     */
    protected function playerStateChanged_v1 (key :String, value :Object) :void
    {
        avrgDispatch(AVRGameControlEvent.PLAYER_PROPERTY_CHANGED, key, value);
    }

    /**
     * Called when a user message has arrived.
     */
    protected function messageReceived_v1 (key :String, value :Object) :void
    {
        avrgDispatch(AVRGameControlEvent.MESSAGE_RECEIVED, key, value);
    }

    /**
     * Called when a quest has been added or removed from our list of active quests.
     */
    protected function questStateChanged_v1 (questId :String, state :Boolean) :void
    {
        avrgDispatch(AVRGameControlEvent.QUEST_STATE_CHANGED, questId, state);
    }
}
}
