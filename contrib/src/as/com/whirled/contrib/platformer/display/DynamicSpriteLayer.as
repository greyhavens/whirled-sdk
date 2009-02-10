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

import com.whirled.contrib.platformer.piece.Dynamic;
import com.whirled.contrib.platformer.util.Metrics;

public class DynamicSpriteLayer extends Layer
{
    public function addDynamicSprite (ds :DynamicSprite) :void
    {
        _dynamics.push(ds);
        showDS(ds);
    }

    public function removeDynamicSprite (d :Dynamic) :void
    {
        for (var ii :int = 0; ii < _dynamics.length; ii++) {
            if (_dynamics[ii].getDynamic() == d) {
                removeDS(_dynamics[ii]);
                _dynamics[ii].shutdown();
                _dynamics.splice(ii, 1);
                break;
            }
        }
    }

    public function updateSprites (delta :Number, ids :Array = null) :void
    {
        for each (var ds :DynamicSprite in _dynamics) {
            if (ids == null || ids.indexOf(ds.getDynamic().id) != -1) {
                ds.update(delta);
            }
        }
    }

    override public function shutdown () :void
    {
        for each (var ds :DynamicSprite in _dynamics) {
            removeDS(ds);
            ds.shutdown();
        }
    }

    override public function update (nX :Number, nY :Number, scale :Number = 1) :void
    {
        super.update(nX, nY);
        for each (var ds :DynamicSprite in _dynamics) {
            showDS(ds);
        }
    }

    protected function showDS (ds :DynamicSprite) :void
    {
        if (!ds.showAlways() && (ds.x < -x - ds.width - IN_BUFFER ||
                ds.x > -x + Metrics.DISPLAY_WIDTH + ds.width + IN_BUFFER ||
                ds.y < -y - ds.height - IN_BUFFER ||
                ds.y > -y + Metrics.DISPLAY_HEIGHT + ds.height + IN_BUFFER)) {
            removeDS(ds);
        } else {
            addDS(ds);
        }
    }

    protected function removeDS (ds :DynamicSprite) :void
    {
        if (ds.parent == this) {
            removeChild(ds);
        }
    }

    protected function addDS (ds :DynamicSprite) :void
    {
        if (ds.parent == null) {
            addChild(ds);
        }
    }

    protected var _dynamics :Array = new Array();

    protected static const IN_BUFFER :int = Metrics.DISPLAY_HEIGHT/3;
    protected static const OUT_BUFFER :int = IN_BUFFER * 2;

}
}
