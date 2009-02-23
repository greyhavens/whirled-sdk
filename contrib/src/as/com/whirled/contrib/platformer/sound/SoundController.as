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
            addBinding(bindFadein(_track = playSound(trackSound, 0), SoundType.MUSIC));
        } else {
            _track = playSound(trackSound, backgroundVolume);
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

    public function playEffect (effect :SoundEffect) :void
    {
        if (!SOUND_ENABLED || effect.playType == PlayType.PLACEHOLDER) {
            return;
        }

        if (effect.playType == PlayType.RESTARTING) {
            stopEffect(effect);

        } else if (effect.playType == PlayType.CONTINUOUS && _channels.containsKey(effect)) {
            return;
        }

        startEffectPlayback(effect);
    }

    public function stopEffect (effect :SoundEffect) :void
    {
        var playback :ChannelPlayback = _channels.remove(effect);
        if (playback != null) {
            playback.channel.stop();
            _eventMgr.freeAllOn(playback.channel);
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

    protected function getSound (effect :SoundEffect) :Sound
    {
        var sound :Sound = _sounds.get(effect.sound);
        if (sound == null) {
            var cls :Class = _contentDomain.getDefinition(effect.sound) as Class;
            sound = cls == null ? null : (new cls()) as Sound;
            if (sound == null) {
                log.warning("Sound effect not found!", "name", effect.sound);
            } else {
                _sounds.put(effect.sound, sound);
            }
        }
        return sound;
    }

    protected function bindChannelRemoval (effect :SoundEffect) :Function
    {
        return function () :void {
            _channels.remove(effect);
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

    protected function bindFadein (channel :SoundChannel, type :SoundType) :Function
    {
        var endTime :int = getTimer() + FADE_TIME;
        return function () :Boolean {
            var targetVolume :Number = type == SoundType.EFFECT ? effectsVolume : backgroundVolume;
            var time :int = getTimer();
            if (time >= endTime) {
                channel.soundTransform = new SoundTransform(targetVolume);
                return true;
            }

            channel.soundTransform =
                new SoundTransform(targetVolume * (1 - (endTime - time) / FADE_TIME));
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
        _track = playSound(sound, effectsVolume);
        _eventMgr.registerListener(_track, Event.SOUND_COMPLETE, loopTrack);
    }

    protected function playSound (sound :Sound, volume :Number) :SoundChannel
    {
        return sound.play(0, 0, new SoundTransform(volume));
    }

    protected function startEffectPlayback (effect :SoundEffect) :void
    {
        var sound :Sound = getSound(effect);
        if (sound == null) {
            log.warning("No sound found for effect", "effect", effect);
            return;
        }

        var channel :SoundChannel = playSound(sound, effectsVolume);
        if (effect.playType != PlayType.OVERLAPPING) {
            _channels.put(effect, new ChannelPlayback(channel, getTimer()));
            _eventMgr.registerOneShotCallback(
                channel, Event.SOUND_COMPLETE, bindChannelRemoval(effect));
        }
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

import com.threerings.util.Enum;

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

final class SoundType extends Enum
{
    public static const MUSIC :SoundType = new SoundType("MUSIC");
    public static const EFFECT :SoundType = new SoundType("EFFECT");
    finishedEnumerating(SoundType);

    public static function values () :Array
    {
        return Enum.values(SoundType);
    }

    public static function valueOf (name :String) :SoundType
    {
        return Enum.valueOf(SoundType, name) as SoundType;
    }

    // @private
    public function SoundType (name :String)
    {
        super(name);
    }
}
