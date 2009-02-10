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

package com.whirled.contrib.platformer {

import com.whirled.game.GameControl;

import com.whirled.contrib.platformer.board.Board;
import com.whirled.contrib.platformer.game.GameController;
import com.whirled.contrib.platformer.net.MessageManager;
import com.whirled.contrib.platformer.piece.PieceFactory;
import com.whirled.contrib.platformer.persist.PersistenceManager;

public class PlatformerContext
{
    public static var platformer :PlatformerController;
    public static var controller :GameController;
    public static var gctrl :GameControl;
    public static var board :Board;
    public static var pfac :PieceFactory;
    public static var net :MessageManager;
    public static var local :Boolean;
    public static var persist :PersistenceManager;
    public static var myId :int;
    public static var effectEnum :Class;

    public static function get inControl () :Boolean
    {
        return local || PlatformerContext.gctrl.game.amServerAgent();
    }
}
}
