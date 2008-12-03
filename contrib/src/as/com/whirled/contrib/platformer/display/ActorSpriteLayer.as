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

import com.whirled.contrib.platformer.util.Metrics;

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
        super.update(nX, nY);
        for each (var acts :ActorSprite in _dynamics) {
            //trace("x: " + x + ", acts.x: " + acts.x);
            if (acts.x < -x - acts.width || acts.x > -x + Metrics.DISPLAY_WIDTH + acts.width) {
                removeDS(acts);
            } else {
                if (acts.parent == null) {
                    addDS(acts);
                } else if ((acts.parent == this) != acts.getDynamic().isAlive()) {
                    removeDS(acts);
                    addDS(acts);
                }
            }
        }
    }

    override protected function removeDS (ds :DynamicSprite) :void
    {
        if (ds.parent == _deathLayer) {
            _deathLayer.removeChild(ds);
        } else {
            super.removeDS(ds);
        }
    }

    protected function addDS (ds :DynamicSprite) :void
    {
        if (ds.getDynamic().isAlive()) {
            addChild(ds);
        } else {
            _deathLayer.addChild(ds);
        }
    }

    protected var _deathLayer :Sprite;
}
}
