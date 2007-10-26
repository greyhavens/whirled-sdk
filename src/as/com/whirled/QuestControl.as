//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled {

import flash.display.DisplayObject;

/**
 * Dispatched when a quest is added or removed from a player's set of active quests.
 * 
 * @eventType com.whirled.AVRGameControlEvent.QUEST_STATE_CHANGED
 */
[Event(name="questStateChanged", type="com.whirled.AVRGameControlEvent")]

/**
 * Defines actions, accessors and callbacks available to all Quests.
 */
public class QuestControl extends WhirledSubControl
{
    public function QuestControl (ctrl :WhirledControl)
    {
        super(ctrl);
    }

    public function offerQuest (questId :String, intro :String, initialStatus :String) :Boolean
    {
        return _ctrl.callHostCodeFriend("offerQuest_v1", questId, intro, initialStatus);
    }

    public function updateQuest (questId :String, step :int, status :String) :Boolean
    {
        return _ctrl.callHostCodeFriend("updateQuest_v1", questId, step, status);
    }

    public function completeQuest (questId :String, outro :String, payout :int) :Boolean
    {
        return _ctrl.callHostCodeFriend("completeQuest_v1", questId, outro, payout);
    }

    public function cancelQuest (questId :String) :Boolean
    {
        return _ctrl.callHostCodeFriend("cancelQuest_v1", questId);
    }

    public function getActiveQuests () :Array
    {
        return _ctrl.callHostCodeFriend("getActiveQuests_v1");
    }

    internal function populateSubProperties (o :Object) :void
    {
         o["questStateChanged_v1"] = questStateChanged_v1;
    }

    /**
     * Called when a quest has been added or removed from our list of active quests.
     */
    protected function questStateChanged_v1 (questId :String, state :Boolean) :void
    {
        dispatchEvent(new AVRGameControlEvent(
            AVRGameControlEvent.QUEST_STATE_CHANGED, questId, state));
    }
}
}
