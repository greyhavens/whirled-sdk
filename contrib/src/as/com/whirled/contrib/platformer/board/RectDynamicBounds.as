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

package com.whirled.contrib.platformer.board {

import com.whirled.contrib.platformer.game.RectDynamicController;
import com.whirled.contrib.platformer.piece.BoundData;
import com.whirled.contrib.platformer.piece.Rect;
import com.whirled.contrib.platformer.piece.RectDynamic;

public class RectDynamicBounds extends DynamicBounds
    implements SimpleBounds
{
    public var lines :Array;

    public function RectDynamicBounds (rdc :RectDynamicController, c :Collider)
    {
        super(rdc, c);
        var rd :RectDynamic = rdc.getDynamic() as RectDynamic;
        lines = new Array();
        lines.push(new LineData(rd.x, rd.y, rd.x, rd.y+rd.height, BoundData.ALL));
        lines.push(new LineData(
                rd.x, rd.y+rd.height, rd.x+rd.width, rd.y+rd.height, BoundData.ALL));
        lines.push(new LineData(rd.x+rd.width, rd.y+rd.height, rd.x+rd.width, rd.y, BoundData.ALL));
        lines.push(new LineData(rd.x+rd.width, rd.y, rd.x, rd.y, BoundData.ALL));
        _rect.width = rd.width;
        _rect.height = rd.height;
    }

    public function getBoundLines () :Array
    {
        return lines;
    }

    public function getMovementBoundLines () :Array
    {
        return lines;
    }

    override public function translate (dX :Number, dY :Number) :void
    {
        // no translation
    }
}
}
