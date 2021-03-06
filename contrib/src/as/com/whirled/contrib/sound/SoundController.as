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

import flash.errors.IOError;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.net.URLRequest;
import flash.utils.Timer;
import flash.utils.getTimer; // function import

import com.threerings.util.Log;
import com.threerings.util.Map;
import com.threerings.util.Maps;

import com.threerings.util.EventHandlerManager;
import com.whirled.contrib.LevelPackManager;
import com.whirled.contrib.LevelPacks;

[Event(name="backgroundMusicComplete", type="flash.events.Event")]

public class SoundController extends EventDispatcher
{
    public static const SOUND_ENABLED :Boolean = true;

    public static const BACKGROUND_MUSIC_COMPLETE :String = "backgroundMusicComplete";

    /**
     * @param factory The sound factory to use to fetch sound effects.  If none is provided,
     *                a default ApplicationDomainSoundFactory is created that uses the currentDomain
     * @param initialBackgroundVolume The initial value of the background volume
     * @param initialEffectsVolume The initial volume of sound effects
     * @param levelPackMgr Background music is defined as MP3s that are loaded out of game level
     *                     packs.  If no LevelPackManager is provided, LevelPacks.getGlobalManager()
     *                     is used.
     */
    public function SoundController (factory :SoundFactory = null,
        initialBackgroundVolume :Number = 0.5,
        initialEffectsVolume :Number = 0.5,
        levelPackMgr :LevelPackManager = null)
    {
        _soundFactory = factory == null ? new ApplicationDomainSoundFactory() : factory;
        _backgroundVolume = initialBackgroundVolume;
        _effectsVolume = initialEffectsVolume;
        _levelPackMgr = levelPackMgr == null ? LevelPacks.getGlobalManager() : levelPackMgr;
        _timer = new Timer(1); // fire every frame;
        _timer.addEventListener(TimerEvent.TIMER, tick);
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
            var trackURL :String = _levelPackMgr.getMediaURL(name);
            if (trackURL == null) {
                log.warning("level pack for track not found", "name", name);
                return;
            }
            trackSound = new Sound();
            trackSound.addEventListener(IOErrorEvent.IO_ERROR, function (...ignored) :void {});
            try {
                trackSound.load(new URLRequest(trackURL));
            } catch (ioe :IOError) {
                log.warning("Failed to load background music", "ioe", ioe);
                return;
            }
            _tracks.put(name, trackSound);
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
            stopEffect(effect, id);

        } else if (effect.playType == PlayType.CONTINUOUS && _channels.containsKey(key)) {
            return;
        }

        var sound :Sound = _soundFactory.getSound(effect.sound);
        if (sound == null) {
            log.warning("No sound found for effect", "effect", effect);
            return;
        }

        var dist :Number =
            location == null ? 0 : Point.distance(location, new Point(0, 0)) / DISTANCE_NORMALIZE;
        var pan :Number = location == null ? 0 : location.x;
        var channel :SoundChannel = playSound(sound, effectsVolume * (1 - dist), pan);
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
        _timer.stop();
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
        if (_tickBindings.length == 0) {
            _timer.stop();
        }
    }

    protected function addBinding (binding :Function) :void
    {
        _tickBindings.push(binding);
        _timer.start(); // only starts if not already started
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

    protected var _eventMgr :EventHandlerManager = new EventHandlerManager();
    protected var _channels :Map = Maps.newMapOf(String);
    protected var _tracks :Map = Maps.newMapOf(String);
    protected var _track :SoundChannel;
    protected var _trackName :String;
    protected var _tickBindings :Array = [];
    protected var _backgroundVolume :Number;
    protected var _effectsVolume :Number;
    protected var _soundFactory :SoundFactory;
    protected var _levelPackMgr :LevelPackManager;

    protected var _timer :Timer;

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
