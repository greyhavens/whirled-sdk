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
    public function DynamicSpriteLayer ()
    {
        super();
        scaleX = Metrics.SCALE;
        scaleY = Metrics.SCALE;
    }

    override public function get displayCount () :int
    {
        return numChildren;
    }

    public function addDynamicSprite (ds :DynamicSprite) :void
    {
        _dynamics.push(ds);
        showDS(ds);
    }

    public function removeDynamicSprite (d :Dynamic) :void
    {
        for (var ii :int = 0; ii < _dynamics.length; ii++) {
            if (_dynamics[ii].getDynamic() == d) {
                removeSprite(_dynamics[ii]);
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
        switch (ds.showState()) {
        case DynamicSprite.ALWAYS:
            addDS(ds);
            break;
        case DynamicSprite.NEVER:
            removeDS(ds);
            break;
        case DynamicSprite.UNTIL_REMOVED:
            if (ds.parent == null) {
                removeDS(ds);
                break;
            }
            // drop through
        default :
            if (offScreen(ds)) {
                removeDS(ds);
            } else {
                addDS(ds);
            }
        }
    }

    protected function offScreen (ds :DynamicSprite) :Boolean
    {
        var w :Number = ds.displayWidth;
        var h :Number = ds.displayHeight;
        return ((ds.x + w < -x / Metrics.SCALE ||
                ds.x - w > (-x + Metrics.DISPLAY_WIDTH) / Metrics.SCALE ||
                ds.y + h < -y / Metrics.SCALE ||
                ds.y - h > (-y + Metrics.DISPLAY_HEIGHT) / Metrics.SCALE));
    }

    protected function removeDS (ds :DynamicSprite) :Boolean
    {
        if (ds.parent == this) {
            removeChild(ds);
        }
        if (ds.showState() == DynamicSprite.UNTIL_REMOVED ||
                ds.showState() == DynamicSprite.NEVER) {
            removeSprite(ds);
            return true;
        }
        return false;
    }

    protected function addDS (ds :DynamicSprite) :void
    {
        if (ds.parent == null) {
            addChild(ds);
        }
    }

    protected function removeSprite (ds :DynamicSprite) :void
    {
        if (ds.parent != null) {
            removeDS(ds);
        }
        ds.shutdown();
        var idx :int = _dynamics.indexOf(ds);
        if (idx != -1) {
            _dynamics.splice(idx, 1);
        }
    }

    protected var _dynamics :Array = new Array();

    protected static const IN_BUFFER :int = Metrics.DISPLAY_HEIGHT/3;
    protected static const OUT_BUFFER :int = IN_BUFFER * 2;

}
}
