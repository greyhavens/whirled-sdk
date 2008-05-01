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

import com.threerings.flash.Vector2;
import com.whirled.contrib.card.trick.Trick;
import com.whirled.contrib.card.Table;
import flash.geom.Point;

/** Graphic for the cards in the main trick (in the center of the table). Supports animation from 
 *  the local and remote players. */
public class MainTrickSprite extends TrickSprite
{
    /** Creates a new main trick sprite. 
     *  @param target The trick that this sprite represents
     *  @param playerSprites An array of player sprite, relative to the local player
     *  @param localHand The sprite representing the local player's hand */
    public function MainTrickSprite (
        target :Trick, 
        seating :Table,
        playerSprites :Array, 
        localHand :HandSprite)
    {
        super(target, seating, localHand.factory);
        _playerSprites = playerSprites;
        _localHand = localHand;
    }

    /** Remove all the card sprites and return an array containing them. This should only be 
     *  called if the underlying trick is about to be reset, i.e. on a 
     *  CardArrayEvent.ACTION_PRERESET action. Otherwise a crash will occur.
     *  TODO: handle this using internal listener so caveat is not needed. */
    public function orphanCards () :Array
    {
        _cards.forEach(remove);
        var cards :Array = _cards;
        _cards = new Array();
        return cards;

        function remove (card :CardSprite, i :int, a :Array) :void {
            removeChild(card);
        }
    }

    /** inheritDoc */
    // from CardArraySprite
    override protected function animateAddition (card :CardSprite) :void
    {
        var idx :int = _cards.indexOf(card);
        var seat :int = _seating.getSeatAlong(
            _seating.getRelativeFromId(_trick.leader), idx);

        var start :Vector2;

        // check if card is from local player
        if (seat == 0 && _localHand != null) {

            // use card from the local hand (if available)
            var removals :Array = _localHand.finalizeRemovals();
            var handCard :CardSprite = removals.length > 0 ? 
                (removals[0] as CardSprite) : null;

            if (handCard != null) {
                start = new Vector2(handCard.x, handCard.y);
            }
            else {
                start = new Vector2(0, -_factory.getCardHeight());
            }
                
            // convert to local coordinates
            start = Vector2.fromPoint(globalToLocal(
                _localHand.localToGlobal(start.toPoint())));
        }
        else {
            start = Vector2.fromPoint(globalToLocal(
                _playerSprites[seat].localToGlobal(new Point(0, 0))));
        }

        // set the starting position
        var card :CardSprite = _cards[idx];
        card.x = start.x;
        card.y = start.y;

        // get the finish position
        var finish :Vector2 = new Vector2();
        getStaticCardPosition(idx, finish);

        // tween it
        var tween :Object = {
            x : finish.x,
            y : finish.y,
            time : FLY_IN_DURATION
        };
        LocalTweener.addTween(card, tween);
    }

    protected var _playerSprites :Array;
    protected var _localHand :HandSprite;

    protected static const FLY_IN_DURATION :Number = .75;
}

}
