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
import com.whirled.contrib.platformer.client.ClientPlatformerContext;

public class SoundController extends EventDispatcher
{
    public static const SOUND_ENABLED :Boolean = true;

    public function SoundController (dispatcher :EventDispatcher)
    {
        _eventMgr.registerListener(dispatcher, Event.ENTER_FRAME, tick);
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
            addBinding(bindFadein(_track = play(trackSound, 0)));
        } else {
            _track = play(trackSound, backgroundVolume);
        }
        _eventMgr.registerListener(_track, Event.SOUND_COMPLETE, loopTrack);
    }

    public function stopBackgroundMusic (fadeOut :Boolean = true) :void
    {
        if (_track == null) {
            return;
        }

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
    public function continueSoundEffect (effect :Object) :void
    {
        if (!SOUND_ENABLED) {
            return;
        }

        var name :String = getName(effect);
        if (_channels.containsKey(name)) {
            return;
        }

        var sound :Sound = getSound(effect);
        if (sound != null) {
            playEffect(name, sound);
        }
    }

    /**
     * If this sound effect is already playing, stop the current channel.
     */
    public function restartSoundEffect (effect :Object, playTime :int = -1) :void
    {
        if (!SOUND_ENABLED) {
            return;
        }

        var name :String = getName(effect);
        var playback :ChannelPlayback = _channels.get(name);
        if (playback != null) {
            if (playTime != -1 && getTimer() < (playback.startTime + playTime)) {
                return;
            }

            _channels.remove(name);
            playback.channel.stop();
            _eventMgr.freeAllOn(playback.channel);
        }

        var sound :Sound = getSound(effect);
        if (sound != null) {
            playEffect(name, sound);
        }
    }

    /**
     * Players the given sound effect in a new channel, regardless of whether it was already playing
     *
     * TODO: this is disabled because it's not well designed.  If it turns out that we need this
     * method, I'll rework it.  If we don't need it, we can just dump it altogether.
     */
//    public function startSoundEffect (name :String) :void
//    {
//        if (!SOUND_ENABLED) {
//            return;
//        }
//
//        // TODO: This is going to need to be more sophisticated so that these can be included in
//        // _channels.  Probably, _channels will need to be indexed off of some sort of id that
//        // differentiates between a sound effect that should be looped, and a sound effect that
//        // is allowed to have several instances playing simultaneously.
//        var sound :Sound = getSound(name);
//        if (sound != null) {
//            play(sound, effectsVolume);
//        }
//    }

    public function stopSoundEffect (name :String) :void
    {
        var playback :ChannelPlayback = _channels.remove(name);
        if (playback != null) {
            playback.channel.stop();
        }
    }

    public function shutdown () :void
    {
        _eventMgr.freeAllHandlers();
    }

    public function backgroundVolumeModified () :void
    {
        if (_track != null) {
            _track.soundTransform = new SoundTransform(backgroundVolume);
        }
    }

    // convenience getter
    protected function get effectsVolume () :Number
    {
        return ClientPlatformerContext.prefs.effectsVolume;
    }

    // convenience getter
    protected function get backgroundVolume () :Number
    {
        return ClientPlatformerContext.prefs.backgroundVolume;
    }

    protected function onLoaded (...ignored) :void
    {
        _loaded = true;
        dispatchEvent(new Event(Event.COMPLETE));
    }

    protected function getName (effect :Object) :String
    {
        if (effect is String) {
            return effect as String;
        }

        if (effect is EffectSet) {
            return (effect as EffectSet).name;
        }

        log.debug("getName given an invalid effect", "effect", effect);
        return null;
    }

    protected function getSound (effect :Object) :Sound
    {
        var effectName :String
        if (effect is String) {
            effectName = effect as String;

        } else if (effect is EffectSet) {
            effectName = (effect as EffectSet).getRandomEntry();

        } else {
            log.debug("getSound given an invalid effect", "effect", effect);
            return null;
        }

        var sound :Sound = _sounds.get(effectName);
        if (sound == null) {
            var cls :Class = _contentDomain.getDefinition(effectName) as Class;
            sound = cls == null ? null : (new cls()) as Sound;
            if (sound == null) {
                log.warning("Sound effect not found!", "name", effectName);
            } else {
                _sounds.put(effectName, sound);
            }
        }
        return sound;
    }

    protected function bindChannelRemoval (name :String) :Function
    {
        return function () :void {
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
                channel.soundTransform = new SoundTransform(effectsVolume)
                return true;
            }

            channel.soundTransform =
                new SoundTransform(effectsVolume * (1 - (endTime - time) / FADE_TIME));
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
        _track = play(sound, effectsVolume);
        _eventMgr.registerListener(_track, Event.SOUND_COMPLETE, loopTrack);
    }

    protected function play (sound :Sound, volume :Number) :SoundChannel
    {
        return sound.play(0, 0, new SoundTransform(volume));
    }

    protected function playEffect (name :String, effect :Sound) :void
    {
        var channel :SoundChannel = play(effect, effectsVolume);
        _channels.put(name, new ChannelPlayback(channel, getTimer()));
        _eventMgr.registerOneShotCallback(channel, Event.SOUND_COMPLETE, bindChannelRemoval(name));
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

import flash.media.SoundChannel;

class ChannelPlayback
{
    public var channel :SoundChannel;
    public var startTime :int;

    public function ChannelPlayback (channel :SoundChannel, startTime :int)
    {
        this.channel = channel;
        this.startTime = startTime;
    }
}
