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

import flash.media.SoundTransform;

public class AudioControllerBase
    implements AudioController
{
    public function AudioControllerBase (parentControls :AudioControllerContainer = null)
    {
        if (null != parentControls) {
            _parent = parentControls;
            _parent.attachChild(this);
        }
    }

    public function retain () :void
    {
        ++_refCount;
    }

    public function release () :void
    {
        if (--_refCount < 0) {
            throw new Error("Cannot release() below a refCount of 0");
        }
    }

    public function volume (val :Number) :AudioController
    {
        _localState.volume = Math.max(val, 0);
        _localState.volume = Math.min(_localState.volume, 1);
        return this;
    }

    public function volumeTo (targetVal :Number, time :Number) :AudioController
    {
        if (time <= 0) {
            this.volume(targetVal);
            _targetVolumeTotalTime = 0;
        } else {
            _initialVolume = _localState.volume;
            var targetVolume :Number = Math.max(targetVal, 0);
            targetVolume = Math.min(targetVolume, 1);
            _targetVolumeDelta = targetVolume - _initialVolume;
            _targetVolumeElapsedTime = 0;
            _targetVolumeTotalTime = time;
        }

        return this;
    }

    public function fadeOut (time :Number) :AudioController
    {
        return this.volumeTo(0, time);
    }

    public function fadeIn (time :Number) :AudioController
    {
        return this.volumeTo(1, time);
    }

    public function pan (val :Number) :AudioController
    {
        _localState.pan = Math.max(val, -1);
        _localState.pan = Math.min(_localState.pan, 1);
        return this;
    }

    public function panTo (targetVal :Number, time :Number) :AudioController
    {
        if (time <= 0) {
            this.pan(targetVal);
            _targetPanTotalTime = 0;
        } else {
            _initialPan = _localState.pan;
            var targetPan :Number = Math.max(targetVal, -1);
            targetPan = Math.min(targetPan, 1);
            _targetPanDelta = targetPan - _initialPan;
            _targetPanElapsedTime = 0;
            _targetPanTotalTime = time;
        }

        return this;
    }

    public function pause (val :Boolean) :AudioController
    {
        _localState.paused = val;
        _pauseCountdown = 0;
        _unpauseCountdown = 0;
        return this;
    }

    public function pauseAfter (time :Number) :AudioController
    {
        if (time <= 0) {
            this.pause(true);
        } else {
            _pauseCountdown = time;
        }

        return this;
    }

    public function unpauseAfter (time :Number) :AudioController
    {
        if (time <= 0) {
            this.pause(false);
        } else {
            _unpauseCountdown = time;
        }

        return this;
    }

    public function mute (val :Boolean) :AudioController
    {
        _localState.muted = val;
        _muteCountdown = 0;
        _unmuteCountdown = 0;
        return this;
    }

    public function muteAfter (time :Number) :AudioController
    {
        if (time <= 0) {
            this.mute(true);
        } else {
            _muteCountdown = time;
        }

        return this;
    }

    public function unmuteAfter (time :Number) :AudioController
    {
        if (time <= 0) {
            this.mute(false);
        } else {
            _unmuteCountdown = time;
        }

        return this;
    }

    public function stop () :void
    {
        // no-op
    }

    public function update (dt :Number, parentState :AudioState) :void
    {
        if (_targetVolumeTotalTime > 0) {
            _targetVolumeElapsedTime = Math.min(_targetVolumeElapsedTime + dt, _targetVolumeTotalTime);
            var volumeTransition :Number = _targetVolumeElapsedTime / _targetVolumeTotalTime;
            _localState.volume = _initialVolume + (_targetVolumeDelta * volumeTransition);

            if (_targetVolumeElapsedTime >= _targetVolumeTotalTime) {
                _targetVolumeTotalTime = 0;
            }
        }

        if (_targetPanTotalTime > 0) {
            _targetPanElapsedTime = Math.min(_targetPanElapsedTime + dt, _targetPanTotalTime);
            var panTransition :Number = _targetPanElapsedTime / _targetPanTotalTime;
            _localState.pan = _initialPan + (_targetPanDelta * panTransition);

            if (_targetPanElapsedTime >= _targetPanTotalTime) {
                _targetPanTotalTime = 0;
            }
        }

        if (_pauseCountdown > 0) {
            _pauseCountdown = Math.max(_pauseCountdown - dt, 0);
            if (_pauseCountdown == 0) {
                _localState.paused = true;
            }
        }

        if (_unpauseCountdown > 0) {
            _unpauseCountdown = Math.max(_unpauseCountdown - dt, 0);
            if (_unpauseCountdown == 0) {
                _localState.paused = false;
            }
        }

        if (_muteCountdown > 0) {
            _muteCountdown = Math.max(_muteCountdown - dt, 0);
            if (_muteCountdown == 0) {
                _localState.muted = true;
            }
        }

        if (_unmuteCountdown > 0) {
            _unmuteCountdown = Math.max(_unmuteCountdown - dt, 0);
            if (_unmuteCountdown == 0) {
                _localState.muted = false;
            }
        }

        AudioState.combine(_localState, parentState, _globalState);
    }

    public function computeState () :AudioState
    {
        if (null != _parent) {
            AudioState.combine(_localState, _parent.computeState(), _globalState);
            return _globalState;
        } else {
            return _localState;
        }
    }

    public function get needsCleanup () :Boolean
    {
        return (_refCount <= 0);
    }

    protected var _parent :AudioControllerContainer;

    protected var _refCount :int;

    protected var _localState :AudioState = new AudioState();
    protected var _globalState :AudioState = new AudioState();

    protected var _initialVolume :Number = 0;
    protected var _targetVolumeDelta :Number = 0;
    protected var _targetVolumeElapsedTime :Number = 0;
    protected var _targetVolumeTotalTime :Number = 0;

    protected var _initialPan :Number = 0;
    protected var _targetPanDelta :Number = 0;
    protected var _targetPanElapsedTime :Number = 0;
    protected var _targetPanTotalTime :Number = 0;

    protected var _pauseCountdown :Number = 0;
    protected var _unpauseCountdown :Number = 0;
    protected var _muteCountdown :Number = 0;
    protected var _unmuteCountdown :Number = 0;
}

}
