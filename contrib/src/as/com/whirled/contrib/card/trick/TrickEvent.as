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
import com.whirled.contrib.card.Card;

/** 
 * Represents something that happens to a trick.
 */
public class TrickEvent extends Event
{
    /** The type of event when a card is played. For this event, the card property is set to the 
     *  card played and the player property is set to the player who played the card. */
    public static const CARD_PLAYED :String = "trick.cardPlayed";

    /** The type of event when the trick is reset. For this event, the card and player properties 
     *  are not set.*/
    public static const RESET :String = "trick.reset";

    /** The type of event when the trick is complete. For this event, the card property is set to 
     *  the winning card and the player property to the winning player and the player property is 
     *  set to the winner. */
    public static const COMPLETED :String = "trick.complete";

    /** The type of event when the player who is currently winning the trick is changed. For this 
     *  event, the card is set to the card that has just been played and the player is set to the 
     *  winning player. */
    public static const FRONTRUNNER_CHANGED :String = "trick.frontrunner";

    /** Create a new TrickEvent. */
    public function TrickEvent(
        type :String, 
        card :Card = null, 
        player :int = 0)
    {
        super(type);
        _card = card;
        _player = player;
    }

    /** @inheritDoc */
    // from flash.events.Event
    override public function clone () :Event
    {
        return new TrickEvent(type, _card, _player);
    }

    /** @inheritDoc */
    // from Object
    override public function toString () :String
    {
        return formatToString("TrickEvent", "type", "bubbles", "cancelable", 
            "card", "player");
    }

    /** The player that put down the card or the player that has won the trick. */
    public function get player () :int
    {
        return _player;
    }

    /** The card that has been played or the card that has won the trick. */
    public function get card () :Card
    {
        return _card;
    }

    protected var _player :int;
    protected var _card :Card;
}

}
