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

package com.whirled.contrib.platformer.sound {

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.utils.getTimer; // function import

import com.threerings.util.HashMap;
import com.threerings.util.Log;

import com.whirled.contrib.EventHandlerManager;
import com.whirled.contrib.LevelPacks;
import com.whirled.contrib.ZipMultiLoader;

public class SoundController extends EventDispatcher
{
    public static const SOUND_ENABLED :Boolean = true;

    public static const DEFAULT_VOLUME :Number = 0.6;

    public function SoundController (dispatcher :EventDispatcher)
    {
        _eventMgr.registerListener(dispatcher, Event.ENTER_FRAME, tick);
    }

    public function get volume () :Number
    {
        // TODO: controls for volume?
        return DEFAULT_VOLUME;
    }

    public function initZip (source :Object) :void
    {
        if (SOUND_ENABLED) {
            new ZipMultiLoader(source, onLoaded, _contentDomain);
        }
    }

    public function get loaded () :Boolean
    {
        return _loaded;
    }

    public function whenLoaded (callback :Function) :void
    {
        _eventMgr.conditionalCall(callback, loaded, this, Event.COMPLETE);
    }

    public function startBackgroundMusic (name :String, crossfade :Boolean = true) :void
    {
        if (!SOUND_ENABLED) {
            return;
        }

        log.debug("startBackgroundMusic", "name", name);

        stopBackgroundMusic(crossfade);

        var trackSound :Sound = _tracks.get(_trackName = name) as Sound;
        if (_track == null) {
            var trackURL :String = LevelPacks.getMediaURL(name);
            if (trackURL == null) {
                log.warning("level pack for track not found", "name", name);
                return;
            }
            _tracks.put(name, trackSound = new Sound(new URLRequest(trackURL)));
        }

        if (crossfade) {
            addBinding(bindFadein(_track = trackSound.play(0, 0, new SoundTransform(0))));
        } else {
            _track = trackSound.play(0, 0, new SoundTransform(volume));
        }
        _eventMgr.registerListener(_track, Event.SOUND_COMPLETE, loopTrack);
    }

    public function stopBackgroundMusic (fadeOut :Boolean = true) :void
    {
        if (_track == null) {
            return;
        }

        log.debug("stopBackgroundMusic", "name", _trackName, "channel", _track);

        if (fadeOut) {
            addBinding(bindFadeout(_track));
        } else {
            _track.stop();
        }
        _eventMgr.unregisterListener(_track, Event.SOUND_COMPLETE, loopTrack);
        _track = null;
    }

    /**
     * If start is true, continueSoundEffect will be called.  If start is false, stopSoundEffect
     * will be called.
     */
    public function setEffectPlayback (name :String, start :Boolean) :void
    {
        if (!SOUND_ENABLED) {
            return;
        }

        if (start) {
            continueSoundEffect(name);
        } else {
            stopSoundEffect(name);
        }
    }

    /**
     * If the given sound effect has a channel allocated and is playing, nothing happens.
     * Otherwise, a new channel is allocated and the sound effect begins.
     */
    public function continueSoundEffect (name :String) :void
    {
        if (!SOUND_ENABLED) {
            return;
        }

        if (_channels.containsKey(name)) {
            return;
        }

        var sound :Sound = _sounds.get(name);
        if (sound == null) {
            var cls :Class = _contentDomain.getDefinition(name) as Class;
            sound = cls == null ? null : (new cls()) as Sound;
            if (sound == null) {
                log.warning("Sound effect not found!", "name", name);
                return;
            }

            _sounds.put(name, sound);
        }

        var channel :SoundChannel = sound.play(0, 0, new SoundTransform(volume));
        _channels.put(name, channel);
        _eventMgr.registerOneShotCallback(channel, Event.SOUND_COMPLETE, bindChannelRemoval(name));
    }

    public function stopSoundEffect (name :String) :void
    {
        var channel :SoundChannel = _channels.remove(name);
        if (channel != null) {
            channel.stop();
        }
    }

    public function shutdown () :void
    {
        _eventMgr.freeAllHandlers();
    }

    protected function onLoaded (...ignored) :void
    {
        _loaded = true;
        dispatchEvent(new Event(Event.COMPLETE));
    }

    protected function bindChannelRemoval (name :String) :Function
    {
        return function () :void {
            log.debug("sound complete", "name", name);
            _channels.remove(name);
        };
    }

    protected function bindFadeout (channel :SoundChannel) :Function
    {
        var endTime :int = getTimer() + FADE_TIME;
        var startVolume :Number = channel.soundTransform.volume;
        return function () :Boolean {
            var time :int = getTimer();
            if (time >= endTime) {
                channel.stop();
                return true;
            }

            channel.soundTransform = new SoundTransform(startVolume * (endTime - time) / FADE_TIME);
            return false;
        };
    }

    protected function bindFadein (channel :SoundChannel) :Function
    {
        var endTime :int = getTimer() + FADE_TIME;
        return function () :Boolean {
            var time :int = getTimer();
            if (time >= endTime) {
                channel.soundTransform = new SoundTransform(volume)
                return true;
            }

            channel.soundTransform =
                new SoundTransform(volume * (1 - (endTime - time) / FADE_TIME));
            return false;
        };
    }

    protected function tick (...ignored) :void
    {
        for (var ii :int = 0; ii < _tickBindings.length; ii++) {
            if (_tickBindings[ii]()) {
                _tickBindings.splice(ii, 1);
                ii--;
            }
        }
    }

    protected function addBinding (binding :Function) :void
    {
        _tickBindings.push(binding);
    }

    protected function loopTrack (...ignored) :void
    {
        if (_track != null) {
            _eventMgr.unregisterListener(_track, Event.SOUND_COMPLETE, loopTrack);
            _track = null;
        }

        if (_trackName == null) {
            return;
        }

        var sound :Sound = _tracks.get(_trackName);
        if (sound == null) {
            log.warning("No cached Sound for a looping track", "trackName", _trackName);
        }
        _track = sound.play(0, 0, new SoundTransform(volume));
        _eventMgr.registerListener(_track, Event.SOUND_COMPLETE, loopTrack);
    }

    protected var _contentDomain :ApplicationDomain = new ApplicationDomain(null);
    protected var _eventMgr :EventHandlerManager = new EventHandlerManager();
    protected var _loaded :Boolean = false;
    protected var _sounds :HashMap = new HashMap();
    protected var _channels :HashMap = new HashMap();
    protected var _tracks :HashMap = new HashMap();
    protected var _track :SoundChannel;
    protected var _trackName :String;
    protected var _tickBindings :Array = [];

    protected static const FADE_TIME :int = 3 * 1000; // in ms

    private static const log :Log = Log.getLog(SoundController);
}
}
