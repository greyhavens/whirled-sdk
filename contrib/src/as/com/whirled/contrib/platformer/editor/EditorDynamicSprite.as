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

package com.whirled.contrib.platformer.editor {

import com.whirled.contrib.platformer.display.DynamicSprite;
import com.whirled.contrib.platformer.piece.Actor;
import com.whirled.contrib.platformer.piece.Dynamic;

public class EditorDynamicSprite extends EditorSprite
{
    public function EditorDynamicSprite (ds :DynamicSprite, es :BoardEditSprite)
    {
        super(ds, es);

        _dynamic = ds.getDynamic();
        name = _dynamic.id.toString();
        ds.setStatic(true);
    }

    override public function update () :void
    {
        (_sprite as DynamicSprite).update(0);
    }

    override public function getTileX () :Number
    {
        return _dynamic.x;
    }

    override public function getTileY () :Number
    {
        return _dynamic.y;
    }

    override public function getTileWidth () :Number
    {
        if (_dynamic.hasOwnProperty("width")) {
            return (_dynamic as Object).width;
        } else {
            return 1;
        }
    }

    override public function getTileHeight () :Number
    {
        if (_dynamic.hasOwnProperty("height")) {
            return (_dynamic as Object).height;
        } else {
            return 1;
        }
    }

    override public function mouseMove (newX :int, newY :int) :void
    {
        if (!isNaN(_startX)) {
            _dynamic.x = Math.max(0, newX - _startX);
            _dynamic.y = Math.max((_dynamic is Actor ? 0.01 : 0), newY - _startY);
            update();
        }
    }

    protected var _dynamic :Dynamic;
}
}
