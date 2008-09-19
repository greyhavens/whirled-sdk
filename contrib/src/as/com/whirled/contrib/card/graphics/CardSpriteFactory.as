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

import com.whirled.contrib.card.Card;

/** Defines functions to be used by classes that need to interact with card graphics,
 *  mainly CardArraySprite and subclasses. */
public interface CardSpriteFactory
{
    /** Create a card sprite.
     *  @param card the (immutable) card that the sprite represents */
    function createCard (card :Card) :CardSprite;

    /** Get the width of a card sprite (used for static layout). */
    function getCardWidth () :int;
    
    /** Get the height of a card sprite (used for static layout). */
    function getCardHeight () :int;
}

}
