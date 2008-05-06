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

import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;

public class GameSoundChannel extends AudioControllerBase
{
    public function GameSoundChannel (parentControls :AudioControllerContainer = null)
    {
        super(parentControls);
        _soundTransform = new SoundTransform();
    }

    public function play (sound :Sound) :void
    {
        _sound = sound;
        this.playInternal(0);
    }

    protected function playInternal (startTime :Number) :void
    {
        this.stop();

        _channel = _sound.play(startTime, _soundTransform);
        _channel.addEventListener(Event.SOUND_COMPLETE, handleComplete);
        _isPlaying = true;
        _paused = false;
    }

    override public function stop () :void
    {
        if (null != _channel) {
            _channel.removeEventListener(Event.SOUND_COMPLETE, handleComplete);
            _channel.stop();
            _channel = null;
            _isPlaying = false;
            _paused = false;
        }
    }

    public function get isPlaying () :Boolean
    {
        return _isPlaying;
    }

    protected function handleComplete (...ignored) :void
    {
        _isPlaying = false;
        _channel = null;
    }

    override public function get needsCleanup () :Boolean
    {
        return (!_isPlaying && super.needsCleanup);
    }

    override public function update (dt :Number, parentVolume :Number, parentPan :Number, parentPaused :Boolean, parentMuted :Boolean) :void
    {
        super.update(dt, parentVolume, parentPan, parentPaused);

        // update volume/pan
        var muted :Boolean = (_localMuted || parentMuted);
        _soundTransform.volume = (muted ? 0 : _localVolume * parentVolume);
        _soundTransform.pan = (parentPan != 0 ? parentPan : _localPan); // @TODO - do something else with pan here?

        // update paused
        var paused :Boolean = _localPaused || parentPaused;
        if (paused && !_paused && _isPlaying) {
            _savedPosition = _channel.position;
            this.stop();
            // stop() sets isPlaying and paused to false, but we still consider the sound to be playing
            _isPlaying = true;
            _paused = true;
        } else if (!paused && _paused) {
            this.playInternal(_savedPosition);
        }
    }

    protected var _sound :Sound;
    protected var _channel :SoundChannel;
    protected var _soundTransform :SoundTransform;
    protected var _savedPosition :Number;
    protected var _isPlaying :Boolean;
}

}
