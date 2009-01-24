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

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.events.Event;
import flash.filters.ColorMatrixFilter;

public class CacheWrapper
{
    public function CacheWrapper (name :String, disp :DisplayObject)
    {
        _disp = disp;
        _name = name;
    }

    public function get disp () :DisplayObject
    {
        return _disp;
    }

    public function get name () :String
    {
        return _name;
    }

    public function start () :void
    {
        if (_disp is MovieClip) {
            (_disp as MovieClip).gotoAndPlay(1);
        }
        if (_recolor != null && _filter != null) {
            DisplayUtils.recolorNodes(_recolor, _disp, _filter);
            _filter = null;
        }
    }

    public function reset (...ignored) :void
    {
        _disp.removeEventListener(Event.COMPLETE, onComplete);
        if (_disp.parent != null) {
            _disp.parent.removeChild(_disp);
        }
        if (_disp is MovieClip) {
            (_disp as MovieClip).stop();
        }
        PieceSpriteFactory.returnCacheClip(this);
    }

    public function resetOnComplete () :void
    {
        _disp.addEventListener(Event.COMPLETE, reset);
    }

    public function recolor (node :String, filter :ColorMatrixFilter) :void
    {
        if (_recolor != null && _filter == null) {
            DisplayUtils.recolorNodes(_recolor, _disp, null);
        }
        if (node != null && filter != null) {
            _filter = filter;
        } else {
            node = null;
        }
        _recolor = node;
    }

    protected function onComplete (...ignored) :void
    {
        reset();
    }

    protected var _disp :DisplayObject;
    protected var _name :String;
    protected var _recolor :String;
    protected var _filter :ColorMatrixFilter;
}
}
