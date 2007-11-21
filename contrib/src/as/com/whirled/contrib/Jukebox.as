// $Id$

package com.whirled.contrib {

import flash.events.Event;
import flash.events.IEventDispatcher;

import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;

import flash.net.URLRequest;

import flash.utils.getTimer;

import com.threerings.util.HashMap;
import com.threerings.util.Log;

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
     */
    public static function init (frameDispatcher :IEventDispatcher) :void {
        _frameDispatcher = frameDispatcher;
    }

    /**
     * Start a background audio track.
     * 
     * @param trackName the name of the level pack that contains the MP3 for this track.
     * @param crossfade If true, this track will fade in, and any previous track will fade out.  If
     *                  false, this track will begin playing immediately.
     */
    public static function start (trackName :String, crossfade :Boolean = true) :void
    {
        var song :Sound = _sounds.get(trackName) as Sound;
        if (song == null) {
            var trackUrl :String = LevelPacks.getMediaURL(trackName);
            if (trackUrl == null) {
                log.warning("level pack for track not found! [" + trackName + "]");
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
                    EventHandlers.unregisterEventListener(
                        _frameDispatcher, Event.ENTER_FRAME, fadeInner);
                } else {
                    _currentChannel.soundTransform = 
                        new SoundTransform((
                            _volume = targetVolume * (time - startTime) / FADE_TIME) / 100);
                }
            }
        }(getTimer(), realVolume);
        EventHandlers.registerEventListener(_frameDispatcher, Event.ENTER_FRAME, fadeInner);
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

            EventHandlers.unregisterEventListener(_currentChannel, Event.SOUND_COMPLETE, loop);
            var fadeOutter :Function;
            fadeOutter = function (startTime :int, channel :SoundChannel, 
                    startVolume :Number) :Function {
                return function (... ignored) :void {
                    var time :int = getTimer();
                    if (time > startTime + FADE_TIME) {
                        channel.stop();
                        EventHandlers.unregisterEventListener(
                            _frameDispatcher, Event.ENTER_FRAME, fadeOutter);
                    } else {
                        channel.soundTransform = 
                            new SoundTransform(startVolume * (1 - (time - startTime) / FADE_TIME));
                    }
                }
            }(getTimer(), _currentChannel, _currentChannel.soundTransform.volume);
            EventHandlers.registerEventListener(_frameDispatcher, Event.ENTER_FRAME, fadeOutter);
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
            EventHandlers.unregisterEventListener(_currentChannel, Event.SOUND_COMPLETE, loop);
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

    protected static function loop (... ignored) :void
    {
        if (_currentChannel != null) {
            EventHandlers.unregisterEventListener(_currentChannel, Event.SOUND_COMPLETE, loop);
        }
        _currentChannel = _currentSong.play(0, 0, new SoundTransform(_volume / 100));
        if (_currentChannel != null) {
            EventHandlers.registerEventListener(_currentChannel, Event.SOUND_COMPLETE, loop);
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

    protected static var _sounds :HashMap = new HashMap();

    private static var log :Log = Log.getLog(Jukebox);
}
}
