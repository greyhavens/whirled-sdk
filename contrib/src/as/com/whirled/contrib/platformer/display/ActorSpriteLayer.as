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

package com.whirled.contrib.platformer.display {

import flash.display.Sprite;

public class ActorSpriteLayer extends DynamicSpriteLayer
{
    public function ActorSpriteLayer ()
    {
        super();
        _deathLayer = new Sprite();
        addChild(_deathLayer);
    }

    override public function update (nX :Number, nY :Number, scale :Number = 1) :void
    {
        super.update(nX, nY, scale);
        if (_count != numChildren) {
            _count = numChildren;
        }
    }

    override protected function removeDS (ds :DynamicSprite) :Boolean
    {
        if (ds.parent == _deathLayer) {
            _deathLayer.removeChild(ds);
        }
        return super.removeDS(ds);
    }

    override protected function addDS (ds :DynamicSprite) :void
    {
        if (ds.parent == null) {
            addAS(ds);
        } else if ((ds.parent == this) != ds.getDynamic().isAlive()) {
            if (!removeDS(ds)) {
                addAS(ds);
            }
        }
    }

    protected function addAS (ds :DynamicSprite) :void
    {
        if (ds.getDynamic().isAlive()) {
            if (ds.forceBack()) {
                addChildAt(ds, 0);
            } else {
                addChild(ds);
            }
        } else {
            _deathLayer.addChild(ds);
        }
    }

    protected var _deathLayer :Sprite;
    protected var _count :int;
}
}
