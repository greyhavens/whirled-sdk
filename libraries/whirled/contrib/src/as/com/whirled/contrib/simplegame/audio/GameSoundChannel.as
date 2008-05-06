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
        _startTime = 0;
        this.playInternal();
    }

    protected function playInternal () :void
    {
        this.stop();

        // update the global sound state immediately
        this.computeState();
        _soundTransform.volume = _globalState.muted ? 0 : _globalState.volume;
        _soundTransform.pan = _globalState.pan;

        if (!_globalState.paused) {
            _channel = _sound.play(_startTime, 0, _soundTransform);
            _channel.addEventListener(Event.SOUND_COMPLETE, handleComplete);
        }

        _isPlaying = true;
    }

    override public function stop () :void
    {
        if (null != _channel) {
            _channel.removeEventListener(Event.SOUND_COMPLETE, handleComplete);
            _channel.stop();
            _channel = null;
            _isPlaying = false;
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

    override public function update (dt :Number, parentState :AudioControllerState) :void
    {
        var wasPaused :Boolean = _globalState.paused;

        super.update(dt, parentState);

        // update paused
        if (_isPlaying) {
            // update paused state
            if (!wasPaused && _globalState.paused) {
                _startTime = _channel.position;
                this.stop();
                // stop() sets isPlaying to false, but we still consider the sound to be playing
                _isPlaying = true;
            } else if (wasPaused && !_globalState.paused) {
                this.playInternal();
            } else {
                // update the sound transform
                _soundTransform.volume = _globalState.muted ? 0 : _globalState.volume;
                _soundTransform.pan = _globalState.pan;

                // Simply modifying the channel's existing sound transform isn't sufficient.
                // We need to reassign the SoundTransform to the channel to get the change
                // to stick.
                // @TODO - is it less expensive if we do this only when the sound transform
                // has actually changed?
                _channel.soundTransform = _soundTransform;
            }
        }
    }

    protected var _sound :Sound;
    protected var _channel :SoundChannel;
    protected var _soundTransform :SoundTransform;
    protected var _startTime :Number;
    protected var _isPlaying :Boolean;
}

}
