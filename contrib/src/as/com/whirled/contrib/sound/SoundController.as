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

package com.whirled.contrib.sound {

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.SampleDataEvent;
import flash.geom.Point;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.utils.ByteArray;
import flash.utils.getTimer; // function import

import com.threerings.util.HashMap;
import com.threerings.util.Log;
import com.threerings.util.MethodQueue;

import com.whirled.contrib.EventHandlerManager;
import com.whirled.contrib.LevelPacks;
import com.whirled.contrib.ZipMultiLoader;

[Event(name="backgroundMusicComplete", type="flash.events.Event")]

public class SoundController extends EventDispatcher
{
    public static const SOUND_ENABLED :Boolean = true;

    public static const BACKGROUND_MUSIC_COMPLETE :String = "backgroundMusicComplete";

    /* For Testing Purposes */
    public var soundTick :int;
    public var stopTick :int;
    public var soundsPlayed :int;

    public function SoundController (initialBackgroundVolume :Number = 0.5,
        initialEffectsVolume :Number = 0.5)
    {
        _backgroundVolume = initialBackgroundVolume;
        _effectsVolume = initialEffectsVolume;

        MethodQueue.callLater(tick);
    }

    public function get effectsVolume () :Number
    {
        return _effectsVolume;
    }

    public function set effectsVolume (value :Number) :void
    {
        _effectsVolume = value;
    }

    public function get backgroundVolume () :Number
    {
        return _backgroundVolume;
    }

    public function set backgroundVolume (value :Number) :void
    {
        _backgroundVolume = value;
        if (_track != null) {
            _track.soundTransform = new SoundTransform(_backgroundVolume);
        }
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

    public function startBackgroundMusic (name :String, crossfade :Boolean = true,
        loop :Boolean = true) :void
    {
        if (!SOUND_ENABLED) {
            return;
        }

        if (name == _trackName) {
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
            _track = playSound(trackSound, 0);
            if (_track != null) {
                addBinding(bindFadein(_track, SoundType.MUSIC));
            }
        } else {
            _track = playSound(trackSound, backgroundVolume);
        }
        if (_track != null) {
            _eventMgr.registerOneShotCallback(_track, Event.SOUND_COMPLETE, function () :void {
                if (loop) {
                    loopTrack();
                }
                dispatchEvent(new Event(BACKGROUND_MUSIC_COMPLETE));
            });
        }
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
        _trackName = null;
    }

    /**
     * Location indicates how far off center the sound should feel to the user.  The pure distance
     * from (0, 0) indicates the overall volume level that the effect will play at, and the x value
     * indicates how far left/right the sound will be panned.
     *
     * The location point x and y values should be normalized to a [-1, 1] scale.
     */
    public function playEffect (effect :SoundEffect, id :int = 0, location :Point = null) :void
    {
        if (!SOUND_ENABLED || effect.playType == PlayType.PLACEHOLDER || effectsVolume == 0) {
            return;
        }

        var key :String = getKey(effect, id);
        if (effect.playType == PlayType.RESTARTING) {
            var now :int = getTimer();
            stopEffect(effect, id);
            stopTick += getTimer() - now;

        } else if (effect.playType == PlayType.CONTINUOUS && _channels.containsKey(key)) {
            return;
        }

        var sound :Sound = getSound(effect);
        if (sound == null) {
            log.warning("No sound found for effect", "effect", effect);
            return;
        }

        var dist :Number =
            location == null ? 0 : Point.distance(location, new Point(0, 0)) / DISTANCE_NORMALIZE;
        var pan :Number = location == null ? 0 : location.x;
        now = getTimer();
        var channel :SoundChannel = playSound(sound, effectsVolume * (1 - dist), pan);
        soundsPlayed++;
        soundTick += getTimer() - now;
        if (channel != null && effect.playType != PlayType.OVERLAPPING) {
            _channels.put(key, new ChannelPlayback(channel, getTimer()));
            _eventMgr.registerOneShotCallback(
                channel, Event.SOUND_COMPLETE, bindChannelRemoval(key));
        }
    }

    public function stopEffect (effect :SoundEffect, id :int) :void
    {
        var playback :ChannelPlayback = _channels.remove(getKey(effect, id));
        if (playback != null) {
            playback.channel.stop();
            _eventMgr.freeAllOn(playback.channel);
        }
    }

    public function shutdown () :void
    {
        _eventMgr.freeAllHandlers();
        if (_track != null) {
            _track.stop();
        }
        _channels.forEach(function (key :String, value :ChannelPlayback) :void {
            if (value != null) {
                value.channel.stop();
            }
        });
    }

    protected function onLoaded (...ignored) :void
    {
        _loaded = true;
        dispatchEvent(new Event(Event.COMPLETE));
    }

    protected function getSound (effect :SoundEffect) :Sound
    {
        var soundName :String = effect.sound;
        var bytes :ByteArray = _sounds.get(soundName);
        if (bytes == null) {
            var cls :Class = _contentDomain.getDefinition(soundName) as Class;
            var source :Sound = cls == null ? null : (new cls()) as Sound;
            if (source == null) {
                log.warning("Sound effect not found!", "name", soundName);
            } else {
                bytes = new ByteArray();
                while (source.extract(bytes, 8192) > 0);
                _sounds.put(soundName, bytes);
            }
        }

        var offset :int = 0;
        var sound :Sound = new Sound();
        var provideSound :Function;
        // each sample is 8 bytes in length, and we want to provide chunks of 8192 samples, as
        // recommended by the docs
        var sampleEventByteSize :int = 8192 * 8;
        provideSound = function (event :SampleDataEvent) :void {
            if (offset + sampleEventByteSize <= bytes.length) {
                event.data.writeBytes(bytes, offset, sampleEventByteSize);
                offset += sampleEventByteSize;

            } else {
                event.data.writeBytes(bytes, offset, bytes.length - offset);
                _eventMgr.unregisterListener(sound, SampleDataEvent.SAMPLE_DATA, provideSound);
            }
        };
        _eventMgr.registerListener(sound, SampleDataEvent.SAMPLE_DATA, provideSound);
        return sound;
    }

    protected function bindChannelRemoval (key :String) :Function
    {
        return function () :void {
            _channels.remove(key);
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
        MethodQueue.callLater(tick);
    }

    protected function addBinding (binding :Function) :void
    {
        _tickBindings.push(binding);
    }

    protected function loopTrack () :void
    {
        var trackName :String = _trackName;
        stopBackgroundMusic(false);
        startBackgroundMusic(trackName, false);
    }

    protected function playSound (sound :Sound, volume :Number, pan :Number = 0) :SoundChannel
    {
        return sound.play(0, 0, new SoundTransform(volume, pan));
    }

    protected function getKey (effect :SoundEffect, id :int) :String
    {
        // id is only honored for CONTINUOUS sounds right now.
        id = effect.playType == PlayType.CONTINUOUS ? id : 0;
        return id + ":" + effect.hashCode();
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
    protected var _backgroundVolume :Number;
    protected var _effectsVolume :Number;

    protected static const DISTANCE_NORMALIZE :Number =
        Point.distance(new Point(0, 0), new Point(1, 1));

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
