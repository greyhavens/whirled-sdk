//
// $Id$

package com.whirled.contrib {

import flash.events.Event;

import flash.media.SoundChannel;
import flash.media.SoundTransform;

import flash.utils.Dictionary;

/**
 * A very simple sound manager for letting you globally adjust the volume
 * on a number of different sounds. Volume can be faded by combining this with Tweener.
 */
public class SimpleSoundManager
{
    /**
     * Construct a SimpleSoundManager.
     */
    public function SimpleSoundManager ()
    {
        _baseVols = new Dictionary();
    }

    /**
     * Set the global volume of all the registered SoundChannels.
     * @param volume a value between 1 (full volume) to 0 (silent).
     */
    public function setGlobalVolume (volume :Number) :void
    {
        if (_volume == volume) {
            return; // no change
        }

        // set it, adjust all
        _volume = volume;
        for (var c :Object in _baseVols) {
            adjustVolume(SoundChannel(c));
        }
    }

    /**
     * Add a sound channel to be tracked. The initial volume level of this channel is
     * taken to be the "base" sound level, so that when the global volume is adjusted this
     * channel will adjust between 0 and the base.
     * The channel will be automatically removed when it stops.
     */
    public function addChannel (channel :SoundChannel) :void
    {
        if (channel == null) {
            return;
        }

        // store the base volume
        _baseVols[channel] = channel.soundTransform.volume;

        adjustVolume(channel);

        channel.addEventListener(Event.SOUND_COMPLETE, handleChannelStopped, false, 0, true);
    }

    /**
     * Stop tracking the specified channel.
     * This does not adjust the volume or stop the sound in any way.
     */
    public function removeChannel (channel :SoundChannel) :void
    {
        if (channel == null) {
            return;
        }

        delete _baseVols[channel];
        channel.removeEventListener(Event.SOUND_COMPLETE, handleChannelStopped, false);
    }

    /**
     * Used to adjust the volume on each channel when registered, or the global volume
     * changes.
     */
    protected function adjustVolume (channel :SoundChannel) :void
    {
        channel.soundTransform.volume = _volume * Number(_baseVols[channel]);
    }

    /**
     * Take care of removing a channel that's been stopped.
     */
    protected function handleChannelStopped (event :Event) :void
    {
        removeChannel(event.target as SoundChannel);
    }

    /** The global volume value. */
    protected var _volume :Number = 1;

    /** A mapping of SoundChannel objects to their base volume. */
    protected var _baseVols :Dictionary;
}
}
