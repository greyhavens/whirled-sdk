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

package com.whirled.contrib {

import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.net.URLRequest;
import flash.utils.getTimer;

import com.threerings.util.EventHandlerManager;
import com.threerings.util.EventHandlers;
import com.threerings.util.Log;
import com.threerings.util.Map;
import com.threerings.util.Maps;

/**
 * A Jukebox class for handling looping background music.
 *
 * This class assumes that each track is a level pack defined for a game, and that
 * com.whirled.contrib.LevelPacks has been initalized with the level packs for this game so that
 * it can call LevelPacks.getMediaURL(trackName) in start() to find out where to download the
 * music from.
 */
public class Jukebox
{
    public static const DEFAULT_VOLUME :int = 30;
    public static const MAX_VOLUME :int = 100;

    /**
     * init must be called before the Jukebox can handle crossfading and loading music correctly.
     * The frameDispatcher must be a display object that will remain on the display list, as this
     * class depends on constant ENTER_FRAME events to function properly.
     *
     * If an EventHandlerManager is provided, all event listeners will be registered using it.
     * Otherwise, EventHandlers is used statically.
     */
    public static function init (frameDispatcher :IEventDispatcher,
        eventMgr :EventHandlerManager = null) :void
    {
        _frameDispatcher = frameDispatcher;
        _eventMgr = eventMgr != null ? eventMgr : EventHandlers.getGlobalManager();
    }

    /**
     * Start a background audio track.
     *
     * @param trackName the name of the level pack that contains the MP3 for this track.
     * @param crossfade If true, this track will fade in, and any previous track will fade out.  If
     *                  false, this track will begin playing immediately.
     * @param callback  A zero-arg function that will be called each time a loop of the current
     *                  song finishes and a new song is about to get played.
     */
    public static function start (trackName :String, crossfade :Boolean = true,
        callback :Function = null) :void
    {
        _loopCallback = callback;
        var song :Sound = _sounds.get(trackName) as Sound;
        if (song == null) {
            var trackUrl :String = LevelPacks.getMediaURL(trackName);
            if (trackUrl == null) {
                log.warning("level pack for track not found! [" + trackName + "]");
                if (crossfade) {
                    fadeOut();
                } else {
                    stop();
                }
                return;
            }
            _sounds.put(trackName, song = new Sound(new URLRequest(trackUrl)));
        }
        startSong(song, crossfade);
    }

    /**
     * Fade the current music in.  Used in crossfading or for fading in music after calling
     * fadeOut().
     */
    public static function fadeIn () :void
    {
        if (_frameDispatcher == null) {
            loop();
            return;
        }

        var realVolume :int = _volume;
        _volume = 0;
        loop();
        if (_currentChannel == null) {
            // if nothing started, there's nothing to fade in
            return;
        }

        var fadeInner :Function;
        fadeInner = function (startTime :int, targetVolume :int) :Function {
            return function (... ignored) :void {
                var time :int = getTimer();
                if (time > startTime + FADE_TIME) {
                    _currentChannel.soundTransform =
                        new SoundTransform((_volume = targetVolume) / 100);
                    _eventMgr.unregisterListener(_frameDispatcher, Event.ENTER_FRAME, fadeInner);
                } else {
                    _currentChannel.soundTransform =
                        new SoundTransform((
                            _volume = targetVolume * (time - startTime) / FADE_TIME) / 100);
                }
            }
        }(getTimer(), realVolume);
        _eventMgr.registerListener(_frameDispatcher, Event.ENTER_FRAME, fadeInner);
    }

    /**
     * Fade the current music out.
     */
    public static function fadeOut () :void
    {
        if (_currentChannel != null) {
            if (_frameDispatcher == null) {
                stop();
                return;
            }

            _eventMgr.unregisterListener(_currentChannel, Event.SOUND_COMPLETE, soundComplete);
            var fadeOutter :Function;
            fadeOutter = function (startTime :int, channel :SoundChannel,
                    startVolume :Number) :Function {
                return function (... ignored) :void {
                    var time :int = getTimer();
                    if (time > startTime + FADE_TIME) {
                        channel.stop();
                        _eventMgr.unregisterListener(
                            _frameDispatcher, Event.ENTER_FRAME, fadeOutter);
                    } else {
                        channel.soundTransform =
                            new SoundTransform(startVolume * (1 - (time - startTime) / FADE_TIME));
                    }
                }
            }(getTimer(), _currentChannel, _currentChannel.soundTransform.volume);
            _eventMgr.registerListener(_frameDispatcher, Event.ENTER_FRAME, fadeOutter);
            _currentChannel = null;
        }
    }

    /**
     * Stop playing the current music.
     */
    public static function stop () :void
    {
        if (_currentChannel != null) {
            _currentChannel.stop();
            _eventMgr.unregisterListener(_currentChannel, Event.SOUND_COMPLETE, soundComplete);
            _currentChannel = null;
        }
    }

    /**
     * Set the volume level as a value between 0 and 100.
     */
    public static function setVolume (volume :int) :void
    {
        _volume = volume;
        if (_currentChannel != null) {
            _currentChannel.soundTransform = new SoundTransform(_volume / 100);
        }
    }

    /**
     * Modify the current volume level by the given amount.  This function will make sure the
     * volume remains within the valid range of 0 to 100.
     */
    public static function modifyVolume (by :int) :int
    {
        // We go by increments of 5 right now, because we're only allowing control by keyboard.
        // If we have a slider in the future, finer grained control will be good.
        var volume :int = Math.min(MAX_VOLUME, Math.max(0, _volume + by * 5));
        setVolume(volume);
        return volume;
    }

    protected static function loop () :void
    {
        if (_currentChannel != null) {
            _eventMgr.unregisterListener(_currentChannel, Event.SOUND_COMPLETE, soundComplete);
        }
        _currentChannel = _currentSong.play(0, 0, new SoundTransform(_volume / 100));
        if (_currentChannel != null) {
            _eventMgr.registerListener(_currentChannel, Event.SOUND_COMPLETE, soundComplete);
        }
    }

    protected static function soundComplete (event :Event) :void
    {
        if (_currentChannel != null) {
            _eventMgr.unregisterListener(_currentChannel, Event.SOUND_COMPLETE, soundComplete);
        }
        loop();
        if (_loopCallback != null) {
            _loopCallback();
        }
    }

    protected static function startSong (song :Sound, crossfade :Boolean) :void
    {
        if (crossfade) {
            fadeOut();
        } else {
            stop();
        }
        if (song != null) {
            _currentSong = song;
        }
        if (_currentSong != null) {
            if (crossfade) {
                fadeIn();
            } else {
                loop();
            }
        }
    }

    protected static const FADE_TIME :int = 3 * 1000; // in ms

    protected static var _volume :int = DEFAULT_VOLUME;
    protected static var _currentChannel :SoundChannel;
    protected static var _currentSong :Sound;
    protected static var _frameDispatcher :IEventDispatcher;
    protected static var _eventMgr :EventHandlerManager;

    protected static var _sounds :Map = Maps.newMapOf(String);

    protected static var _loopCallback :Function = null;

    private static var log :Log = Log.getLog(Jukebox);
}
}
