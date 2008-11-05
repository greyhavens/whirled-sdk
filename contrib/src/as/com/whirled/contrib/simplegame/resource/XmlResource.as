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

import com.threerings.util.Util;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.utils.ByteArray;

public class XmlResource
    implements Resource
{
    public function XmlResource (resourceName :String, loadParams :Object, objectGenerator :Function = null)
    {
        _resourceName = resourceName;
        _loadParams = loadParams;
        _objectGenerator = objectGenerator;
    }

    public function get resourceName () :String
    {
        return _resourceName;
    }

    public function get xml () :XML
    {
        return _xml;
    }

    public function get generatedObject () :*
    {
        return _generatedObject;
    }

    public function load (completeCallback :Function, errorCallback :Function) :void
    {
        _completeCallback = completeCallback;
        _errorCallback = errorCallback;

        if (_loadParams.hasOwnProperty("url")) {
            loadFromURL(_loadParams["url"]);
        } else if (_loadParams.hasOwnProperty("embeddedClass")) {
            loadFromEmbeddedClass(_loadParams["embeddedClass"]);
        } else {
            throw new Error("XmlResourceLoader: either 'url' or 'embeddedClass' must be specified in loadParams");
        }
    }

    protected function loadFromURL (urlString :String) :void
    {
        _urlLoader = new URLLoader();
        _urlLoader.addEventListener(Event.COMPLETE, onComplete);
        _urlLoader.addEventListener(IOErrorEvent.IO_ERROR, handleLoadError);
        _urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleLoadError);

        _urlLoader.load(new URLRequest(_loadParams["url"]));
    }

    protected function loadFromEmbeddedClass (theClass :Class) :void
    {
        var ba :ByteArray = ByteArray(new theClass());
        instantiateXml(ba.readUTFBytes(ba.length));
    }

    public function unload () :void
    {
        if (null != _urlLoader) {
            try {
                _urlLoader.close();
            } catch (e :Error) {
                // swallow the exception
            }
        }
    }

    protected function onComplete (...ignored) :void
    {
        instantiateXml(_urlLoader.data);
    }

    protected function instantiateXml (data :*) :void
    {
        // the XML may be malformed, so catch errors thrown when it's instantiated
        try {
            _xml = Util.newXML(data);
        } catch (e :Error) {
            onError(e.message);
            return;
        }

        // if we have an object generator function, run the XML through it
        if (null != _objectGenerator) {
            try {
                _generatedObject = _objectGenerator(_xml);
            } catch (e :Error) {
                onError(e.message);
                return;
            }
        }

        _completeCallback(this);
    }

    protected function handleLoadError (e :ErrorEvent) :void
    {
        onError(e.text);
    }

    protected function onError (errText :String) :void
    {
        _errorCallback(this, "XmlResourceLoader (" + _resourceName + "): " + errText);
    }

    protected var _resourceName :String;
    protected var _loadParams :Object;
    protected var _urlLoader :URLLoader;
    protected var _xml :XML;
    protected var _generatedObject :*;
    protected var _objectGenerator :Function;
    protected var _completeCallback :Function;
    protected var _errorCallback :Function;
}

}
