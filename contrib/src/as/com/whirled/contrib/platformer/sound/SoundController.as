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
import flash.system.ApplicationDomain;

import com.threerings.util.HashMap;
import com.threerings.util.Log;

import com.whirled.contrib.EventHandlerManager;
import com.whirled.contrib.ZipMultiLoader;

public class SoundController extends EventDispatcher
{
    public function initZip (source :Object) :void
    {
        new ZipMultiLoader(source, onLoaded, _contentDomain);
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
    }

    /**
     * If start is true, continueSoundEffect will be called.  If start is false, stopSoundEffect
     * will be called.
     */
    public function setEffectPlayback (name :String, start :Boolean) :void
    {
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

        var channel :SoundChannel = sound.play();
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

    protected var _contentDomain :ApplicationDomain = new ApplicationDomain(null);
    protected var _eventMgr :EventHandlerManager = new EventHandlerManager();
    protected var _loaded :Boolean = false;
    protected var _sounds :HashMap = new HashMap();
    protected var _channels :HashMap = new HashMap();

    private static const log :Log = Log.getLog(SoundController);
}
}
