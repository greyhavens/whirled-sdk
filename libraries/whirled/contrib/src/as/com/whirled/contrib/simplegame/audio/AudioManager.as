package com.whirled.contrib.simplegame.audio {

import com.threerings.util.Log;
import com.whirled.contrib.simplegame.resource.*;

import flash.events.Event;
import flash.media.SoundTransform;

public class AudioManager
{
    public static function get instance () :AudioManager
    {
        return g_instance;
    }

    public function AudioManager (maxChannels :int = 25)
    {
        if (null != g_instance) {
            throw new Error("AudioManager instance already exists");
        }

        g_instance = this;

        _channels = new Array(maxChannels);
        _freeChannelIds = new Array(maxChannels);
        for (var i :int = 0; i < maxChannels; ++i) {
            // create a channel
            var channel :AudioChannel = new AudioChannel();
            channel.id = i;
            channel.completeHandler = this.createChannelCompleteHandler(channel);

            // stick it in the channel list
            _channels[i] = channel;

            // the channel is currently unused
            _freeChannelIds[i] = i;
        }

        _masterControls = new AudioControls();

        _soundTypeControls = new Array(SoundResourceLoader.TYPE__LIMIT);
        for (i = 0; i < SoundResourceLoader.TYPE__LIMIT; ++i) {
            var subControls :AudioControls = new AudioControls(_masterControls);
            subControls.retain(); // these subcontrols will never be cleaned up
            _soundTypeControls[i] = subControls;
        }
    }

    protected function createChannelCompleteHandler (channel :AudioChannel) :Function
    {
        return function (...ignored) :void { handleComplete(channel); }
    }

    public function get masterControls () :AudioControls
    {
        return _masterControls;
    }

    public function getControlsForSoundType (type :int) :AudioControls
    {
        if (type >= 0 && type < _soundTypeControls.length) {
            return _soundTypeControls[type];
        }

        return null;
    }

    public function shutdown () :void
    {
        g_instance = null;
    }

    public function update (dt :Number) :void
    {
        _masterControls.update(dt, AudioState.defaultState());

        // update all playing sound channels
        for each (var channel :AudioChannel in _channels) {
            if (channel.isPlaying) {
                var audioState :AudioState = channel.controls.state;
                if (audioState.paused && !channel.isPaused) {
                    this.pause(channel);
                } else if (!audioState.paused && channel.isPaused) {
                    this.resume(channel);
                } else {
                    var curTransform :SoundTransform = channel.channel.soundTransform;
                    var curVolume :Number = curTransform.volume;
                    var curPan :Number = curTransform.pan;
                    var newVolume :Number = audioState.actualVolume;
                    var newPan :Number = audioState.pan;
                    if (newVolume != curVolume || newPan != curPan) {
                        channel.channel.soundTransform = new SoundTransform(newVolume, newPan);
                    }
                }
            }
        }
    }

    public function playSoundNamed (name :String, parentControls :AudioControls = null, loopCount :int = 0) :AudioChannel
    {
        var rsrc :SoundResourceLoader = ResourceManager.instance.getResource(name) as SoundResourceLoader;
        if (null == rsrc) {
            return new AudioChannel();
        }

        return this.playSound(rsrc, parentControls, loopCount);
    }

    public function playSound (soundResource :SoundResourceLoader, parentControls :AudioControls = null, loopCount :int = 0) :AudioChannel
    {
        if (null == soundResource.sound) {
            log.info("Discarding sound '" + soundResource.resourceName + "' (sound is null)");
            return null;
        }

        var timeNow :Number = new Date().time;

        // Iterate the active channels to determine if this sound has been played recently.
        // Also look for the lowest-priority active channel.
        var lowestPriorityChannel :AudioChannel;
        var channel :AudioChannel;
        for each (channel in _channels) {
            if (channel.isPlaying) {
                if (channel.sound == soundResource && (timeNow - channel.startTime) < SOUND_PLAYED_RECENTLY_DELTA) {
                    log.info("Discarding sound '" + soundResource.resourceName + "' (recently played)");
                    return new AudioChannel();
                }

                if (null == lowestPriorityChannel || channel.sound.priority < lowestPriorityChannel.sound.priority) {
                    lowestPriorityChannel = channel;
                }
            }
        }

        if (_freeChannelIds.length > 0) {
            channel = _channels[int(_freeChannelIds.pop())];
        } else if (null != lowestPriorityChannel && soundResource.priority > lowestPriorityChannel.sound.priority) {
            // Steal another channel from a lower-priority sound
            log.info("Interrupting sound '" + lowestPriorityChannel.sound.resourceName + "' for higher-priority sound '" + soundResource.resourceName + "'");
            this.stop(lowestPriorityChannel);
            channel = _channels[int(_freeChannelIds.pop())];
        } else {
            // we're out of luck.
            log.info("Discarding sound '" + soundResource.resourceName + "' (no free AudioChannels)");
            return new AudioChannel();
        }

        // get the appropriate parent controls
        if (null == parentControls) {
            parentControls = this.getControlsForSoundType(soundResource.type);
            if (null == parentControls) {
                parentControls = _masterControls;
            }
        }

        var audioState :AudioState = parentControls.updateStateNow();

        // start playing
        if (!audioState.paused) {
            channel.channel = soundResource.sound.play(0, 0, new SoundTransform(audioState.actualVolume, audioState.pan));

            // Sound.play() will return null if Flash runs out of sound channels
            if (null == channel.channel) {
                log.info("Discarding sound '" + soundResource.resourceName + "' (Flash is out of channels)");
                return new AudioChannel();
            }

            channel.channel.addEventListener(Event.SOUND_COMPLETE, channel.completeHandler);
        }

        // finish initialization of channel
        channel.controls = new AudioControls(parentControls);
        channel.controls.retain();
        channel.sound = soundResource;
        channel.playPosition = 0;
        channel.startTime = timeNow;
        channel.loopCount = loopCount;

        return channel;
    }

    public function stop (channel :AudioChannel) :void
    {
        if (channel.isPlaying) {

            if (null != channel.channel) {
                channel.channel.removeEventListener(Event.SOUND_COMPLETE, channel.completeHandler);
                channel.channel.stop();
                channel.channel = null;
            }

            channel.controls.release();
            channel.controls = null;

            channel.sound = null;

            _freeChannelIds.push(channel.id);
        }
    }

    public function pause (channel :AudioChannel) :void
    {
        if (channel.isPlaying && !channel.isPaused) {
            // save the channel's current play position
            channel.playPosition = channel.channel.position;

            // stop playing
            channel.channel.removeEventListener(Event.SOUND_COMPLETE, channel.completeHandler);
            channel.channel.stop();
            channel.channel = null;
        }
    }

    public function resume (channel :AudioChannel) :void
    {
        if (channel.isPlaying && channel.isPaused) {
            var audioState :AudioState = channel.controls.state;
            channel.channel = channel.sound.sound.play(channel.playPosition, 0, new SoundTransform(audioState.actualVolume, audioState.pan));
            if (null == channel.channel) {
                this.stop(channel);
            }
        }
    }

    protected function handleComplete (channel :AudioChannel) :void
    {
        // does the sound need to loop?
        if (channel.loopCount == 0) {
            this.stop(channel);
        } else {
            // try to play again
            var audioState :AudioState = channel.controls.state;
            channel.channel = channel.sound.sound.play(0, 0, new SoundTransform(audioState.actualVolume, audioState.pan));
            if (null == channel.channel) {
                this.stop(channel);
            } else if (channel.loopCount > 0) {
                channel.loopCount--;
            }
        }
    }

    protected var _channels :Array; // of AudioChannels
    protected var _freeChannelIds :Array; // of ints
    protected var _masterControls :AudioControls;
    protected var _soundTypeControls :Array; // of AudioControls

    protected static var g_instance :AudioManager;
    protected static var log :Log = Log.getLog(AudioManager);

    protected static const SOUND_PLAYED_RECENTLY_DELTA :Number = 1000 / 20;
}

}
