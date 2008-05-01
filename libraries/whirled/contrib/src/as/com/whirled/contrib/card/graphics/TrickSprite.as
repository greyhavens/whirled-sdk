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

package com.whirled.contrib.card.graphics {

import com.whirled.contrib.card.Table;
import com.whirled.contrib.card.trick.Trick;
import com.whirled.contrib.card.trick.TrickEvent;
import com.threerings.flash.Vector2;

/** Graphics for the cards in the trick. */
public class TrickSprite extends CardArraySprite
{
    /** Create a new trick sprite */
    public function TrickSprite (
        target :Trick, 
        seating :Table, 
        factory :CardSpriteFactory)
    {
        super(target.cards, factory, false);
        _trick = target;
        _seating = seating;

        positionCards();

        _trick.addEventListener(TrickEvent.FRONTRUNNER_CHANGED, trickListener);
        _trick.addEventListener(TrickEvent.RESET, trickListener);
    }

    /** Set the card that is currently winning, relative to the first card played this round. */
    protected function set winningCard (card :int) :void
    {
        _winningCard = card;
        for (var i :int = 0; i < _cards.length; ++i) {
            var c :CardSprite = _cards[i];
            if (i == _winningCard) {
                c.state = CardSprite.EMPHASIZED;
            }
            else {
                c.state = CardSprite.NORMAL;
            }
        }
    }

    /** Access the card that is currently winning, relative to the first card played this round. */
    protected function get winningCard () :int
    {
        return _winningCard;
    }

    protected function trickListener (event :TrickEvent) :void
    {
        if (event.type == TrickEvent.RESET) {
            winningCard = -1;
        }
        else if (event.type == TrickEvent.FRONTRUNNER_CHANGED) {
            winningCard = _trick.cards.indexOf(event.card);
        }
    }

    /** Use the static proportional positions and the current trick leader to place the cards in 
     * a cross, mimicking the player positions at the table. */
    override protected function getStaticCardPosition (index :int, pos :Vector2) :void
    {
        var leader :int = _seating.getRelativeFromId(_trick.leader);
        var posIdx :int = _seating.getSeatAlong(leader, index);
        var staticPos :Vector2 = CARD_POSITIONS[posIdx] as Vector2;
        pos.x = staticPos.x * _factory.getCardWidth();
        pos.y = staticPos.y * _factory.getCardHeight();
    }

    protected var _trick :Trick;
    protected var _winningCard :int = -1;
    protected var _seating :Table;

    // layout in a cross
    protected static const CARD_POSITIONS :Array = [
        new Vector2(0, 0.5),
        new Vector2(-0.5, 0),
        new Vector2(0, -0.5),
        new Vector2(0.5, 0)];
}

}

