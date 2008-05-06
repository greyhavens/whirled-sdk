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
            parentControls.attachChild(this);
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
        _localVolume = Math.max(val, 0);
        _localVolume = Math.min(_localVolume, 1);
        return this;
    }

    public function volumeTo (targetVal :Number, time :Number) :AudioController
    {
        if (time <= 0) {
            this.volume(targetVal);
            _targetVolumeTotalTime = 0;
        } else {
            _initialVolume = _localVolume;
            var targetVolume :Number = Math.max(targetVal, 0);
            targetVolume = Math.min(_targetVolume, 1);
            _targetVolumeDelta = targetVolume - volume;
            _targetVolumeElapsedTime = 0;
            _targetVolumeTotalTime = time;
        }

        return this;
    }

    public function fadeOut (time :Number) :AudioController
    {
        return this.volumeTo(0, time);
    }

    public function fadeIn (time) :AudioController
    {
        return this.volumeTo(1, time);
    }

    public function pan (val :Number) :AudioController
    {
        _localPan = Math.max(val, -1);
        _localPan = Math.min(_localPan, 1);
        return this;
    }

    public function panTo (targetVal :Number, time :Number) :AudioController
    {
        if (time <= 0) {
            this.pan(targetVal);
            _targetPanTotalTime = 0;
        } else {
            _initialPan = _localPan;
            var targetPan :Number = Math.max(targetVal, -1);
            targetPan = Math.min(_targetPan, 1);
            _targetPanDelta = targetPan - _initialPan;
            _targetPanElapsedTime = 0;
            _targetPanTotalTime = time;
        }

        return this;
    }

    public function pause () :AudioController
    {
        _localPaused = true;
        _pauseCountdown = 0;
        return this;
    }

    public function resume () :AudioController
    {
        _localPaused = false;
        _pauseCountdown = 0;
        return this;
    }

    public function pauseAfter (time :Number) :AudioController
    {
        if (time <= 0) {
            this.pause();
        } else {
            _pauseCountdown = time;
        }

        return this;
    }

    public function resumeAfter (time :Number) :AudioController
    {
        if (time <= 0) {
            this.resume();
        } else {
            _resumeCountdown = time;
        }

        return this;
    }

    public function stop () :void
    {
        // no-op
    }

    public function update (dt :Number, parentVolume :Number, parentPan :Number, parentPaused :Boolean, parentMuted :Boolean) :void
    {
        if (_targetVolumeTotalTime > 0) {
            _targetVolumeElapsedTime = Math.min(_targetVolumeElapsedTime + dt, _targetVolumeTotalTime);
            var volumeTransition :Number = _targetVolumeElapsedTime / _targetVolumeTotalTime;
            _localVolume = _initialVolume + (_targetVolumeDelta * volumeTransition);

            if (_targetVolumeElapsedTime >= _targetVolumeTotalTime) {
                _targetVolumeTotalTime = 0;
            }
        }

        if (_targetPanTotalTime > 0) {
            _targetPanElapsedTime = Math.min(_targetPanElapsedTime + dt, _targetPanTotalTime);
            var panTransition :Number = _targetPanElapsedTime / _targetPanTotalTime;
            _localPan = _initialPan + (_targetPanDelta * panTransition);

            if (_targetPanElapsedTime >= _targetPanTotalTime) {
                _targetPanTotalTime = 0;
            }
        }

        if (_pauseCountdown >= 0) {
            _pauseCountdown = Math.max(_pauseCountdown - dt, 0);
            if (_pauseCountdown == 0) {
                _localPaused = true;
            }
        }

        if (_resumeCountdown >= 0) {
            _resumeCountdown = Math.max(_resumeCountdown - dt, 0);
            if (_resumeCountdown == 0) {
                _localPaused = false;
            }
        }

        if (_muteCountdown >= 0) {
            _muteCountdown = Math.max(_muteCountdown - dt, 0);
            if (_muteCountdown == 0) {
                _localMuted = true;
            }
        }

        if (_unmuteCountdown >= 0) {
            _unmuteCountdown = Math.max(_unmuteCountdown - dt, 0);
            if (_unmuteCountdown == 0) {
                _localMuted = false;
            }
        }
    }

    public function get needsCleanup () :Boolean
    {
        return (_refCount <= 0);
    }

    protected var _refCount :int;

    protected var _localVolume :Number = 1;
    protected var _initialVolume :Number = 0;
    protected var _targetVolumeDelta :Number = 0;
    protected var _targetVolumeElapsedTime :Number = 0;
    protected var _targetVolumeTotalTime :Number = 0;

    protected var _localPan :Number = 1;
    protected var _initialPan :Number = 0;
    protected var _targetPanDelta :Number = 0;
    protected var _targetPanElapsedTime :Number = 0;
    protected var _targetPanTotalTime :Number = 0;

    protected var _localPaused :Boolean;
    protected var _localMuted :Boolean;

    protected var _pauseCountdown :Number = 0;
    protected var _resumeCountdown :Number = 0;
    protected var _muteCountdown :Number = 0;
    protected var _unmuteCountdown :Number = 0;
}

}
