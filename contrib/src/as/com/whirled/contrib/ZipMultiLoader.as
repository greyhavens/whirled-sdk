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
import flash.events.EventDispatcher;
import flash.events.ProgressEvent;

import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;

import flash.system.ApplicationDomain;

import flash.utils.ByteArray;
import flash.utils.setTimeout;

import com.threerings.util.MultiLoader;

import nochump.util.zip.ZipEntry;
import nochump.util.zip.ZipError;
import nochump.util.zip.ZipFile;

/**
 * Utility class for MultiLoading all the files contained in a zip.
 */
public class ZipMultiLoader extends EventDispatcher
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
            var loader :URLLoader = new URLLoader();
            loader.addEventListener(ProgressEvent.PROGRESS, dispatchEvent);
            loader.dataFormat = URLLoaderDataFormat.BINARY;
            loader.load(req);
            new MultiLoader(loader, loaderLoaded);

        } else {
            bytesAvailable(bytes);
        }
    }

    /**
     * Handle the successful completion of datapack loading.
     */
    protected function loaderLoaded (result :Object) :void
    {
        if (result is Error) {
            _completeCallback(result);

        } else {
            bytesAvailable(ByteArray(URLLoader(result).data));
        }
    }

    /**
     * Read the zip file.
     *
     * @private
     */
    protected function bytesAvailable (bytes :ByteArray) :void
    {
        bytes.position = 0;
        try {
            _zip = new ZipFile(bytes);
        } catch (zipError :ZipError) {
            _completeCallback(zipError);
            return;
        }

        // set up the zip reading state to virginal
        _sources = new Array(_zip.entries.length); 
        _zipIx = 0;

        // and start chomping entries asynchronously
        getNextZipFileEntry();
    }

    protected function getNextZipFileEntry () :void
    {
        try {
            if (_zipIx >= _zip.size) {
                // if we're done, kick off loader & exit
                MultiLoader.getLoaders(_sources, _completeCallback, false, _appDom);
                return;
            }

            // if not yet done, retrieve & store the ix:th zip file entry
            _sources[_zipIx] = _zip.getInput(_zip.entries[_zipIx]);
            // bump our index
            _zipIx ++;
            // and fall out of block to set up the callback

        } catch (e :Error) {
            _completeCallback(e);
            return;
        }

        // arrange an immediate callback to ourselves for the next entry
        setTimeout(getNextZipFileEntry, 1);
    }

    protected var _completeCallback :Function;
    protected var _appDom :ApplicationDomain;
    protected var _loader :URLLoader;

    protected var _sources :Array;
    protected var _zip :ZipFile;
    protected var _zipIx :int;
}
}
