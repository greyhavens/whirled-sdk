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
import com.whirled.contrib.simplegame.audio.*;

import flash.media.Sound;

public class PlaySoundTask
    implements ObjectTask
{
    public function PlaySoundTask (sound :Sound, waitForComplete :Boolean, parentControls :AudioControllerContainer = null)
    {
        _sound = sound;
        _waitForComplete = waitForComplete;
        _parentControls = parentControls;
    }

    public function update (dt :Number, obj :SimObject) :Boolean
    {
        if (null == _channel) {
            _channel = Audio.play(_sound, _parentControls);
        }

        return (!_waitForComplete || !_channel.isPlaying);
    }

    public function clone () :ObjectTask
    {
        return new PlaySoundTask(_sound, _waitForComplete, _parentControls);
    }

    public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        return false;
    }

    protected var _sound :Sound;
    protected var _waitForComplete :Boolean;
    protected var _parentControls :AudioControllerContainer;
    protected var _channel :GameSoundChannel;
}

}
