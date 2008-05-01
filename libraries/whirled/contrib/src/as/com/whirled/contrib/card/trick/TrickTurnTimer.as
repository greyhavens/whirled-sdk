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

import com.whirled.contrib.card.TurnTimer;
import com.whirled.contrib.card.Table;
import com.whirled.game.GameControl;

/** Provides different turn timings for bidding and leading a trick. */
public class TrickTurnTimer extends TurnTimer
{
    /** Creates a new timer. The bids and trick are used to determine the state of the game and 
     *  thus how much time the turn holder should be given to make a move. */
    public function TrickTurnTimer (
        gameCtrl :GameControl, 
        table :Table,
        bids :Bids,
        trick :Trick)
    {
        super(gameCtrl, table);
        _bids = bids;
        _trick = trick;
    }

    /** Access the amount of time allowed for bidding. */
    public function get bidTime () :Number
    {
        return _bidTime;
    }

    /** Access the amount of time allowed for bidding. */
    public function set bidTime (time :Number) :void
    {
        _bidTime = time;
    }

    /** Access the amount of time allowed for leading a trick. */
    public function get leadTime () :Number
    {
        return _leadTime;
    }

    /** Access the amount of time allowed for leading a trick. */
    public function set leadTime (time :Number) :void
    {
        _leadTime = time;
    }

    // inherit docs
    protected override function getCurrentTurnTimeBase (turnHolder :int) :Number
    {
        var seat :int = _table.getAbsoluteFromId(turnHolder);
        var bidding :Boolean = !_bids.hasBid(seat);
        var leading :Boolean = !bidding && _trick.length == 0;

        if (bidding) {
            return _bidTime;
        }
        else if (leading) {
            return _leadTime;
        }
        else {
            return _playTime;
        }
    }

    protected var _bids :Bids;
    protected var _trick :Trick;
    protected var _bidTime :Number = 30;
    protected var _leadTime :Number = 20;
}

}
