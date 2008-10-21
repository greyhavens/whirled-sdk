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

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;

import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;

import flash.system.ApplicationDomain;

import flash.utils.ByteArray;

import com.threerings.util.MultiLoader;

import nochump.util.zip.ZipEntry;
import nochump.util.zip.ZipError;
import nochump.util.zip.ZipFile;

/**
 * Utility class for MultiLoading all the files contained in a zip.
 */
public class ZipMultiLoader
{
    public function ZipMultiLoader (
        source :Object, completeCallback :Function, appDom :ApplicationDomain = null)
    {
        if (source is String) {
            source = new URLRequest(String(source));
        } else if (source is Class) {
            source = new (source as Class)();
        }
        var req :URLRequest = null;
        var bytes :ByteArray;
        if (source is URLRequest) {
            req = URLRequest(source);
        } else if (source is ByteArray) {
            bytes = ByteArray(source);
        } else {
            throw new TypeError("Expected a String or ByteArray");
        }

        _completeCallback = completeCallback;
        _appDom = appDom;

        if (req != null) {
            _loader = new URLLoader();
            _loader.dataFormat = URLLoaderDataFormat.BINARY;
            _loader.addEventListener(Event.COMPLETE, handleLoadingComplete);
            _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleLoadError);
            _loader.addEventListener(IOErrorEvent.IO_ERROR, handleLoadError);
            _loader.load(req);

        } else {
            bytesAvailable(bytes);
        }
    }

    /**
     * Handle some sort of problem loading the datapack.
     *
     * @private
     */
    protected function handleLoadError (event :ErrorEvent) :void
    {
        if (_loader != null) {
            try {
                _loader.close();
            } catch (err :Error) {
                // ignore
            }
            _loader = null;
        }
        dispatchError("Error loading zip file: " + event.text);
    }

    /**
     * Handle the successful completion of datapack loading.
     *
     * @private
     */
    protected function handleLoadingComplete (event :Event) :void
    {
        var ba :ByteArray = ByteArray(_loader.data);
        _loader = null;
        bytesAvailable(ba);
    }

    /**
     * Read the zip file.
     *
     * @private
     */
    protected function bytesAvailable (bytes :ByteArray) :void
    {
        bytes.position = 0;
        var zip :ZipFile;
        try {
            zip = new ZipFile(bytes);
        } catch (zipError :ZipError) {
            dispatchError("Unable to read datapack: " + zipError.message);
            return;
        }

        var sources :Array = new Array();
        for each (var entry :ZipEntry in zip.entries) {
            sources.push(zip.getInput(entry));
        }

        MultiLoader.getLoaders(sources, _completeCallback, false, _appDom);
    }

    protected function dispatchError (error :String) :void
    {
        _completeCallback(new Error(error));
    }

    protected var _loader :URLLoader;
    protected var _completeCallback :Function;
    protected var _appDom :ApplicationDomain;
}
}
