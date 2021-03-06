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

package com.whirled.contrib {

import com.whirled.game.GameControl;

/**
 * A simple card deck for use with games that encodes cards as a string like "Ac" for the
 * ace of clubs, or "Td" for the 10 of diamonds.
 */
public class CardDeck
{
    public function CardDeck (gameCtrl :GameControl, deckName :String = "deck")
    {
        _gameCtrl = gameCtrl;
        _deckName = deckName;

        var deck :Array = new Array();
        for each (var rank :String in ["2", "3", "4", "5", "6", "7", "8",
                "9", "T", "J", "Q", "K", "A"]) {
            for each (var suit :String in ["c", "d", "h", "s"]) {
                deck.push(rank + suit);
            }
        }

        _gameCtrl.services.bags.create(_deckName, deck);
    }

    public function dealToPlayer (
        playerId :int, count :int, msgName :String) :void
    {
        // TODO: support the callback
        _gameCtrl.services.bags.deal(_deckName, count, msgName, null, playerId);
    }

    public function dealToData (count :int, propName :String) :void
    {
        _gameCtrl.services.bags.deal(_deckName, count, propName, null);
    }

    /** The game control. */
    protected var _gameCtrl :GameControl;

    /** The name of our deck. */
    protected var _deckName :String;
}
}
