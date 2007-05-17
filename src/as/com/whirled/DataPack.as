//
// $Id$

package com.whirled {

import flash.display.DisplayObject;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;

import flash.geom.Point;

import flash.net.URLRequest;

import flash.utils.ByteArray;

import com.threerings.util.EmbeddedSwfLoader;
import com.threerings.util.StringUtil;

import deng.fzip.FZip;
import deng.fzip.FZipFile;
import deng.fzip.FZipErrorEvent;
import deng.fzip.FZipEvent;

/**
 * Handles downloading and extracting goodies from a DataPack.
 */
//
// TODO: Much of this class is untested and is currently "beta" quality.
// 
public class DataPack extends EventDispatcher
{
    /**
     * Construct a DataPack to be loaded from specified URL.
     */
    public function DataPack (url :String)
    {
        var req :URLRequest = new URLRequest(url); // throw any errors with the URL immediately

        _zip = new FZip();
        _zip.addEventListener(IOErrorEvent.IO_ERROR, handleLoadError);
        _zip.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleLoadError);
        _zip.addEventListener(FZipErrorEvent.PARSE_ERROR, handleParseError);
        _zip.addEventListener(Event.COMPLETE, handleLoadingComplete);

        _zip.load(req);
    }

    /**
     * Stop loading a DataPack, if not yet complete. You should probably call this
     * during shutdown.
     */
    public function close () :void
    {
        _zip.close();
    }

    /**
     * Has the loading of the datapack completed?
     */
    public function isComplete () :Boolean
    {
        return _complete;
    }

    /**
     * Convenience function to access some data as a String.
     */
    public function getString (name :String) :String
    {
        return getData(name) as String;
    }

    /**
     * Convenience function to access some data as a Number.
     */
    public function getNumber (name :String) :Number
    {
        return getData(name) as Number;
    }

    /**
     * Convenience function to access some data as a Boolean.
     */
    public function getBoolean (name :String) :Boolean
    {
        return getData(name) as Boolean;
    }

    /**
     * Convenience function to access some data as an Array.
     */
    public function getArray (name :String) :Array
    {
        return getData(name) as Array;
    }

    /**
     * Convenience function to access some data as a Point.
     */
    public function getPoint (name :String) :Point
    {
        return getData(name) as Point;
    }

    /**
     * Get some data.
     */
    public function getData (name :String) :*
    {
        if (!_complete) {
            throw new Error("DataPack is not yet completely loaded.");

        } else if (_data == null) {
            throw new Error("DataPack contains no data!");
        }

        var datum :XML = _data..data.(@name == name)[0];
        if (datum == null) {
            return undefined;
        }

        var val :XMLList = datum.@value;
        if (val.length == 0 || val[0] === undefined) {
            return undefined;
        }

        var value :String = String(val[0]);
        trace("Raw value for '" + name + "' is '" + value + "'");
        if (value == null) {
            return undefined;
        }
        var bits :Array;
        switch (String(datum.attribute("type"))) {
        case "String":
            return value;

        case "Boolean":
            return "true" == value.toLowerCase();

        case "Point":
            bits = value.split(",");
            return new Point(parseFloat(bits[0]), parseFloat(bits[1]));

        case "Array":
            return value.split(",").map(StringUtil.trim);

        case "Number":
            return parseFloat(value);

        default:
            trace("Unknown resource type: " + datum.attribute("type"));
            return value;
        }
    }

    /**
     * Get a File, as a ByteArray.
     */
    public function getFile (name :String) :ByteArray
    {
        return getFileInternal(name, false) as ByteArray;
    }

    /**
     * Get a File, as a String.
     */
    public function getFileAsString (name :String) :String
    {
        return getFileInternal(name, true) as String;
    }

    /**
     * Get some display objects in the datapack.
     *
     * @param names an Array of the names of the display objects to load.
     * @param callback a Function that will be called when all the display objects
     *                 are loaded (or were unable to load).
     *                 Signature: function (results :Object) :void
     *                 results will contain a mapping from name -> DisplayObject, or null if none.
     * @param useSubDomain if true, classes in a loaded SWF will be added to an
     *                     ApplicationDomain that is a child of the current ApplicationDomain.
     */
    public function getDisplayObjects (
        names :Array, callback :Function, useSubDomain :Boolean = false) :void
    {
        // our eventual return value
        var dispObjects :Object = {};
        var fileName :String;

        // first, go through and extract the ByteArray for each file,
        // which will also verify the names
        for each (fileName in names) {
            // if a name shows up twice in the list, we only load it once...
            if (!(fileName in dispObjects)) {
                dispObjects[fileName] = getFile(fileName);
            }
        }

        var loaded :int = 0;
        var toLoad :int = 0;
        var loadHandler :Function = function (name :String, disp :DisplayObject) :void {
            // store the result of the load
            dispObjects[name] = disp;

            // see if it's time to call the callback
            if (++loaded == toLoad) {
                callback(dispObjects);
            }
        };

        // now actually load all the ByteArrays we successfully found
        for (fileName in dispObjects) {
            var bytes :ByteArray = dispObjects[fileName] as ByteArray;
            if (bytes != null) {
                toLoad++;
                doLoadDisplayObject(fileName, bytes, loadHandler, useSubDomain);
            }
        }

        // finally, if by some reason there's nothing to load, succeed now
        if (toLoad == 0) {
            callback(dispObjects);
        }
    }

    protected function doLoadDisplayObject (
        name :String, bytes :ByteArray, loadHandler :Function, useSubDomain :Boolean) :void
    {
        var esl :EmbeddedSwfLoader = new EmbeddedSwfLoader(useSubDomain);

        var eslHandler :Function = function (event :Event) :void {
            loadHandler(name, (event.type == Event.COMPLETE) ? esl.getContent() : null);
        }

        esl.addEventListener(Event.COMPLETE, eslHandler);
        esl.addEventListener(IOErrorEvent.IO_ERROR, eslHandler);

        esl.load(bytes);
    }

    protected function getFileInternal (name :String, asString :Boolean) :*
    {
        if (name == null || (0 == name.lastIndexOf("_", 0))) {
            throw new Error("Invalid file name: " + name);
        }

        var file :FZipFile = _zip.getFileByName(name);
        return (file == null) ? null : (asString ? file.getContentAsString() : file.content);
    }

    /**
     * Handle some sort of problem loading the datapack.
     */
    protected function handleLoadError (event :Event) :void
    {
        trace("Error loading datapack: " + event);
        // TODO: mark us as booched, dispatch an event ourselves
    }

    /**
     * Handle some sort of problem parsing datapack.
     */
    protected function handleParseError (event :FZipErrorEvent) :void
    {
        trace("Error parsing datapack: " + event);
        // TODO: mark us as booched, dispatch an event ourselves
    }

    /**
     * Handle the successful completion of datapack loading.
     */
    protected function handleLoadingComplete (event :Event) :void
    {
        try {
            extractDataFile();
            _complete = true;
        } catch (error :Error) {
            // will be handled below
            trace("Oh noes, could not parse the datafile");
        }

        dispatchEvent(_complete ? new Event(Event.COMPLETE)
                                : new ErrorEvent(ErrorEvent.ERROR, false, false,
                                    "Could not parse datapack!"));
    }

    protected function extractDataFile () :void
        // throws Error
    {
        // find the data file
        var dataFile :FZipFile = _zip.getFileByName("_data");
        if (dataFile == null) {
            trace("There appears to be no data file in the DataPack.");
            return;
        }

        try {
            _data = XML(dataFile.getContentAsString());

        } catch (error :Error) {
            trace("Whoa bobby, we couldn't treat the data content as XML..");
        }
    }

    protected var _zip :FZip;

    protected var _complete :Boolean;

    protected var _data :XML;
}
}
