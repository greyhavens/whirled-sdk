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

package com.whirled.contrib.platformer.game {

import com.whirled.contrib.platformer.board.Board;

public class RemoveGatesEventAction extends EventAction
{
    public function RemoveGatesEventAction (gctrl :GameController, xml :XML)
    {
        super(gctrl);
    }

    override public function run () :void
    {
        for (var ii :int = Board.TOP_BOUND; ii <= Board.LEFT_BOUND; ii++) {
            _gctrl.setBound(ii, 0);
        }
    }
}
}
