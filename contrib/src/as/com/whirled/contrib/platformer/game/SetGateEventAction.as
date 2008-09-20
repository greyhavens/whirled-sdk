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

package com.whirled.contrib.platformer.game {

import com.whirled.contrib.platformer.board.Board;

public class SetGateEventAction extends EventAction
{
    public function SetGateEventAction (gctrl :GameController, xml :XML)
    {
        super(gctrl);
        _top = xml["@top"] != null ? xml.@top : -1;
        _left = xml["@left"] != null ? xml.@left : -1;
        _right = xml["@right"] != null ? xml.@right : -1;
        _bottom = xml["@bottom"] != null ? xml.@bottom : -1;
    }

    override public function run () :void
    {
        if (_top != -1) {
            _gctrl.setBound(Board.TOP_BOUND, _top);
        }
        if (_left != -1) {
            _gctrl.setBound(Board.LEFT_BOUND, _left);
        }
        if (_right != -1) {
            _gctrl.setBound(Board.RIGHT_BOUND, _right);
        }
        if (_bottom != -1) {
            _gctrl.setBound(Board.BOTTOM_BOUND, _bottom);
        }
    }

    protected var _top :int;
    protected var _left :int;
    protected var _right :int;
    protected var _bottom :int;
}
}
