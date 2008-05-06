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

package com.whirled.contrib.simplegame.resource {

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.media.Sound;
import flash.net.URLRequest;

public class SoundResourceLoader extends EventDispatcher
    implements ResourceLoader
{
    public function SoundResourceLoader (resourceName :String, loadParams :Object)
    {
        _resourceName = resourceName;
        _loadParams = loadParams;
    }

    public function get resourceName () :String
    {
        return _resourceName;
    }

    public function get sound () :Sound
    {
        return _sound;
    }

    public function load () :void
    {
        // parse loadParams
        if (_loadParams.hasOwnProperty("url")) {
            _sound = new Sound(new URLRequest(_loadParams["url"]));
            _sound.addEventListener(Event.COMPLETE, onInit);
            _sound.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
        } else if (_loadParams.hasOwnProperty("embeddedClass")) {
            try {
                _sound = Sound(new _loadParams["embeddedClass"]());
            } catch (e :Error) {
                this.onError(e.message);
                return;
            }
            this.onInit();
        } else {
            throw new Error("SoundResourceLoader: either 'url' or 'embeddedClass' must be specified in loadParams");
        }
    }

    public function unload () :void
    {
        try {
            if (null != _sound) {
                _sound.close();
            }
        } catch (e :Error) {
            // swallow the exception
        }
    }

    protected function onInit (...ignored) :void
    {
        this.dispatchEvent(new ResourceLoadEvent(ResourceLoadEvent.LOADED));
    }

    protected function onIOError (e :IOErrorEvent) :void
    {
        this.onError(e.text);
    }

    protected function onError (errString :String) :void
    {
        this.dispatchEvent(new ResourceLoadEvent(ResourceLoadEvent.ERROR, "SoundResourceLoader (" + _resourceName + "): " + errString));
    }

    protected var _resourceName :String;
    protected var _loadParams :Object;
    protected var _sound :Sound;
}

}
