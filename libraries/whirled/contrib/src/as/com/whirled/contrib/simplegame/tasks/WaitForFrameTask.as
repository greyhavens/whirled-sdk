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

package com.whirled.contrib.simplegame.tasks {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.components.*;
import com.whirled.contrib.simplegame.objects.*;

import flash.display.MovieClip;

public class WaitForFrameTask implements ObjectTask
{
    public function WaitForFrameTask (frameLabelOrNumber :*)
    {
        if (frameLabelOrNumber is int) {
            _frameNumber = frameLabelOrNumber as int;
        } else if (frameLabelOrNumber is String) {
            _frameLabel = frameLabelOrNumber as String;
        } else {
            throw new Error("frameLabelOrNumber must be a String or an int");
        }
    }

    public function update (dt :Number, obj :SimObject) :Boolean
    {
        var sc :SceneComponent = obj as SceneComponent;
        var movieClip :MovieClip = (null != sc ? sc.displayObject as MovieClip : null);

        if (null == movieClip) {
            throw new Error("WaitForFrameTask can only operate on SceneComponents with MovieClip DisplayObjects");
        }

        return (null != _frameLabel ? movieClip.currentLabel == _frameLabel : movieClip.currentFrame == _frameNumber);
    }

    public function clone () :ObjectTask
    {
        return new WaitForFrameTask(null != _frameLabel ? _frameLabel : _frameNumber);
    }

    public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        return false;
    }

    protected var _frameLabel :String;
    protected var _frameNumber :int;

}

}
