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
import com.whirled.contrib.card.Team;

/** 
 * Represents something that happens to scores.
 */
public class ScoresEvent extends Event
{
    /** Tricks changed. For this event, the team property is the Team object that has just won a 
     *  trick and the value property indicates the current total number of tricks for that team. */
    public static const TRICKS_CHANGED :String = "scores.tricksChanged";

    /** The type of event when the scores change. For this type of event, the team property is the
     *  Team object that has just scored some points and the value property is the current score 
     *  total for that team. */
    public static const SCORES_CHANGED :String = "scores.changed";

    /** The type of event when the tricks are reset to 0. For this type of event, no properties 
     *  are used. */
    public static const TRICKS_RESET :String = "scores.tricksReset";

    /** The type of event when the scores are reset to 0. For this type of event, no properties 
     *  are used. */
    public static const SCORES_RESET :String = "scores.reset";

    /** Placeholder function for Scores subclasses to add new event types. */
    public static function newEventType (type :String) :String
    {
        return type;
    }

    /** Create a new ScoresEvent. */
    public function ScoresEvent(
        type :String, 
        team :Team = null, 
        value :int = -1)
    {
        super(type);
        _team = team;
        _value = value;
    }

    /** @inheritDoc */
    // from flash.events.Event
    override public function clone () :Event
    {
        return new ScoresEvent(type, _team, _value);
    }

    /** @inheritDoc */
    // from Object
    override public function toString () :String
    {
        return formatToString("ScoresEvent", "type", "bubbles", "cancelable", 
            "team", "value");
    }

    /** The team that has just won a trick or scored some points. */
    public function get team () :Team
    {
        return _team;
    }

    /** The current total number of tricks or total score the the team. */
    public function get value () :int
    {
        return _value;
    }

    protected var _team :Team;
    protected var _value :int;
}

}
