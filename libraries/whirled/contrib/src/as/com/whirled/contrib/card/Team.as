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

/** Contains the players on a card game team. */
public class Team
{
    /** Create a new team.
     *  @param index the position of this team in the Table's team array
     *  @param players the absolute seating positions of the players on this team. */
    public function Team (index :int, players :Array)
    {
        _index = index;
        _players = players;
    }

    /** Test if the given absolute seating position is on this team */
    public function hasSeat (seat :int) :Boolean
    {
        return players.indexOf(seat) >= 0;
    }

    /** Access the index of this team in the containing table's team array. */
    public function get index () :int
    {
        return _index;
    }

    /** Access the array of absolute seating positions of the players on this team. */
    public function get players () :Array
    {
        return _players;
    }

    /** @inheritDoc */
    // from Object
    public function toString () :String
    {
        return "Team [index: " + index + ", players: " + players + "]";
    }

    protected var _index :int;
    protected var _players :Array;
}

}
