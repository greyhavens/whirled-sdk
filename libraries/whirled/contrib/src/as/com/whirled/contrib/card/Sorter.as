//
// $Id$
//
// Whirled contrib library - tools for developing whirled games
// Copyright (C) 2002-2008 Three Rings Design, Inc., All Rights Reserved
// http://www.whirled.com/code/contrib/asdocs
//
// This library is free software; you can redistribute it and/or modify it
// under the terms of the GNU Lesser General Public License as published
// by the Free Software Foundation; either version 2.1 of the License, or
// (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

package com.whirled.contrib.card {

/** Sorts cards so that it is easy for a player to assess his hand. */
public class Sorter
{
    public function Sorter (rankOrder :int, suitOrder :Array)
    {
        _rankOrder = rankOrder;
        _suitOrder = suitOrder;
    }

    /** Sort an array of cards. */
    public function sort (cards :CardArray) :void
    {
        cards.standardSort(_suitOrder, _rankOrder);
    }

    /** Insert some new cards into a previously sorted array.
     *  @param newCards the incoming cards
     *  @param cards the previously sorted array
     */
    public function insert(newCards :CardArray, cards :CardArray) :void
    {
        if (cards.length == 0) {
            var sortedNewCards :CardArray = new CardArray(newCards.ordinals);
            sort(sortedNewCards);
            cards.reset(sortedNewCards.ordinals);
        }
        else {
            for (var i :int = 0; i < newCards.length; ++i) {
                cards.sortedInsert(newCards.cards[i], _suitOrder, _rankOrder);
            }
        }
    }

    protected var _rankOrder :int;
    protected var _suitOrder :Array;
}

}
