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

package com.whirled.contrib.simplegame.audio {

import com.whirled.contrib.simplegame.resource.SoundResourceLoader;

import flash.media.SoundChannel;

public class AudioChannel
{
    public function get isPlaying () :Boolean
    {
        return (null != controls);
    }

    public function get isPaused () :Boolean
    {
        return (null != controls && null == channel);
    }

    public function get audioControls () :AudioControls
    {
        return controls;
    }

    public function get debugDescription () :String
    {
        return "sound: '" + sound.resourceName + "' id: " + id;
    }

    // managed by AudioManager

    internal var id :int = -1;
    internal var completeHandler :Function;
    internal var controls :AudioControls;
    internal var sound :SoundResourceLoader;
    internal var channel :SoundChannel;
    internal var playPosition :Number;
    internal var startTime :Number;
    internal var loopCount :int;
}

}
