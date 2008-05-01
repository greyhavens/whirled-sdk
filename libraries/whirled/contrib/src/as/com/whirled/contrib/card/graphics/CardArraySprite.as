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

import flash.display.Sprite;
import com.whirled.contrib.card.Card;
import com.whirled.contrib.card.CardArray;
import com.whirled.contrib.card.CardArrayEvent;
import com.whirled.contrib.card.Debug;
import com.threerings.flash.Vector2;

/**
 * Superclass to display of an array of cards. Delegates layout and some animation to subclasses.
 */
public class CardArraySprite extends Sprite
{
    /** Create a new sprite for a CardArray. The sprite will always listen for all changes on the 
     *  array events and unregister when removed from the display list. Re-adding to the display 
     *  list is not supported. 
     *  @param targer the CardArray to listen to for changes to the sprite
     *  @param deck the embedded deck object to use when creating CardSprite instances
     *  @param doPositioning specify whether to call positionCards */
    public function CardArraySprite (
        target :CardArray, 
        factory :CardSpriteFactory,
        doPositioning :Boolean = true)
    {
        _target = target;
        _factory = factory;

        _target.addEventListener(CardArrayEvent.RESET, cardArrayListener);
        _target.addEventListener(CardArrayEvent.ADDED, cardArrayListener);
        _target.addEventListener(CardArrayEvent.REMOVED, cardArrayListener);

        refresh();

        if (doPositioning) {
            positionCards();
        }
    }

    /** Access the factory for card creation and layout. */
    public function get factory () :CardSpriteFactory
    {
        return _factory;
    }

    /** Update our card sprites with the contents of the target card array. */
    protected function refresh () :void
    {
        _cards.forEach(removeSprite);
        _cards.splice(0, _cards.length);
        _target.cards.forEach(addCard);

        function removeSprite (c :CardSprite, index :int, array :Array) :void
        {
            removeChild(c);
        }

        function addCard (c :Card, index :int, array :Array) :void
        {
            _cards.push(_factory.createCard(c));
            addChild(_cards[index] as Sprite);
        }
    }

    /** Get the x, y position of a card in the array. The base implmentation just lays out the 
     *  cards in a row using some hard-wired constants for width and height. Subclasses should 
     *  override and use more specific values. */
    protected function getStaticCardPosition (i :int, pos :Vector2) :void
    {
        var halfCardWidth :Number = _factory.getCardWidth() / 2;
        var wid :Number = (_cards.length + 1) * halfCardWidth;
        var left :Number = -wid / 2;
        pos.x = left + (i + 1) * halfCardWidth;
        pos.y = 0;
    }

    /** Positions all cards (that are not currently animating). */
    protected function positionCards () :void
    {
        var pos :Vector2 = new Vector2();
        _cards.forEach(positionSprite);

        function positionSprite(c :CardSprite, index :int, arr :Array) :void
        {
            if (!LocalTweener.isTweening(c)) {
                getStaticCardPosition(index, pos);
                c.x = pos.x;
                c.y = pos.y;
            }
        }
    }

    /** When the card array changes, update our child sprites and re-layout. */
    protected function cardArrayListener (event :CardArrayEvent) :void
    {
        Debug.debug("CardArrayEvent received " + event);

        switch (event.type) {

        case CardArrayEvent.RESET:
            refresh();
            break;

        case CardArrayEvent.ADDED:
            _cards.splice(event.index, 0, _factory.createCard(event.card));
            addChildAt(_cards[event.index] as CardSprite, event.index);
            animateAddition(_cards[event.index]);
            break;

        case CardArrayEvent.REMOVED:
            var c: CardSprite = _cards[event.index] as CardSprite;
            _cards.splice(event.index, 1);
            animateRemoval(c);
            break;

        }

        positionCards();
    }

    /** Animates the removal of a card. The _cards array will be taken care of, this function must 
     *  only guarantee that removeChild is called later. By default, just calls removeChild 
     *  immediately. */
    protected function animateRemoval (card :CardSprite) :void
    {
        removeChild(card);
    }

    /** Animates the addition of the card. Default does nothing. Subclasses should set the 
     *  starting position of the card and use slide to move it into its static position. */
    protected function animateAddition (card :CardSprite) :void
    {
    }

    protected var _cards :Array = new Array();
    protected var _target :CardArray;
    protected var _animations :Array = new Array();
    protected var _factory :CardSpriteFactory;
}

}

