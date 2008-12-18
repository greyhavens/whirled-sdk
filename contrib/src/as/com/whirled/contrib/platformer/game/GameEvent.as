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

package com.whirled.contrib.platformer.game {

/**
 * A game event that has a trigger and an action.
 */
public class GameEvent
{
    public static function create (gctrl :GameController, xml :XML) :GameEvent
    {
        if (xml.child("trigger").length() == 0 || xml.child("action").length == 0) {
            trace("no trigger or action children to game event");
            return null;
        }
        var trigger :EventTrigger = EventTrigger.createEventTrigger(gctrl, xml.trigger[0]);
        var action :EventAction = EventAction.createEventAction(gctrl, xml.action[0]);
        if (trigger == null || action == null) {
            return null;
        }
        return new GameEvent(trigger, action,
                xml.hasOwnProperty("@continuous") ? xml.@continous == "true" : false);
    }

    public function GameEvent (trigger :EventTrigger, action :EventAction, continuous :Boolean)
    {
        _trigger = trigger;
        _action = action;
        _continuous = continuous;
    }

    public function isComplete () :Boolean
    {
        return _trigger.hasTriggered();
    }

    public function runEvent () :Boolean
    {
        if (_trigger.checkTriggered()) {
            _action.run();
            return !_continuous;
        }
        return false;
    }

    protected var _trigger :EventTrigger;
    protected var _action :EventAction;
    protected var _continuous :Boolean;
}
}
