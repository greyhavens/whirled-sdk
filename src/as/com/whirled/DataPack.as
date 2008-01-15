//
// $Id$

package com.whirled {

import flash.display.DisplayObject;

import flash.errors.IllegalOperationError;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;

import flash.geom.Point;
import flash.geom.Rectangle;

import flash.net.URLRequest;

import flash.media.Sound;

import flash.utils.ByteArray;

import com.threerings.util.EmbeddedSwfLoader;

import deng.fzip.FZip;
import deng.fzip.FZipFile;
import deng.fzip.FZipErrorEvent;
import deng.fzip.FZipEvent;

/**
 * Dispatched when the DataPack has completed loading.
 *
 * @eventType flash.events.Event.COMPLETE
 */
[Event(name="complete", type="flash.events.Event")]

/**
 * Dispatched when the DataPack could not load due to an error.
 *
 * @eventType flash.events.ErrorEvent.ERROR
 */
[Event(name="error", type="flash.events.ErrorEvent")]

/**
 * Handles downloading and extracting goodies from a DataPack.
 */
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
//        _zip.addEventListener(FZipEvent.FILE_LOADED, handleFileLoaded);
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
        return (_metadata != null);
    }

    public function getNamespace () :String
    {
        validateComplete();
        return unescape(String(_metadata.attribute("namespace")));
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
     * Convenience function to access some data as a color (uint).
     */
    public function getColor (name :String) :uint
    {
        return getData(name) as uint;
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
     * Convenience function to access some data as a Rectangle.
     */
    public function getRectangle (name :String) :Rectangle
    {
        return getData(name) as Rectangle;
    }

    /**
     * Get some data.
     */
    public function getData (name :String) :*
    {
        name = validateAccess(name);

        var datum :XML = _metadata..data.(@name == name)[0];
        if (datum == null) {
            return undefined;
        }

        var val :XMLList = datum.@value;
        if (val.length == 0 || val[0] === undefined) {
            return undefined;
        }

        var value :String = String(val[0]);
        trace("Raw value for data '" + name + "' is '" + value + "'");
        if (value == null) {
            return undefined;
        }
        var bits :Array;
        switch (String(datum.attribute("type"))) {
        case "String":
            return unescape(value);

        case "Number":
            return parseFloat(value);

        case "Boolean":
            return "true" == value.toLowerCase();

        case "Color":
            return parseInt(value, 16);

        case "Array":
            return value.split(",").map(unescape);

        case "Point":
            bits = value.split(",");
            return new Point(parseFloat(bits[0]), parseFloat(bits[1]));

        case "Rectangle":
            bits = value.split(",");
            return new Rectangle(parseFloat(bits[0]), parseFloat(bits[1]),
                parseFloat(bits[2]), parseFloat(bits[3]));

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
     * Get a File, as an XML object.
     */
    public function getFileAsXML (name :String) :XML
    {
        return XML(getFileAsString(name));
    }
    
    /**
     * Get sounds. TODO. This is not quite ready for primetime.
     */
    public function getSounds (names :Array, callback :Function) :void
    {
        var fn :Function = function (obj :Object) :void {
            var newObj :Object = {};

            for (var s :String in obj) {
                var o :Object = obj[s];
                try {
                    o = o["getSound"]();
                } catch (err :Error) {
                    trace("Error getSound: " + err);
                }
                newObj[s] = (o as Sound);
            }

            callback(newObj);
        };

        getDisplayObjects(names, fn);
    }

    /**
     * Get some display objects in the datapack.
     *
     * @param names an Array of the names of the display objects to load.
     * @param callback a Function that will be called when all the display objects
     *                 are loaded (or were unable to load).
     *                 Signature: <code>function (results :Object) :void</code>
     *                 results will contain a mapping from name -> DisplayObject, or null if none.
     * @param useSubDomain if true, classes in a loaded SWF will be added to an
     *                     ApplicationDomain that is a child of the current ApplicationDomain.
     */
    public function getDisplayObjects (
        names :Array, callback :Function, useSubDomain :Boolean = false) :void
    {
        doGetObjects(names, callback, useSubDomain, false);
    }

    /**
     * Get SWF loaders for each SWF in the datapack.
     *
     * @param names an Array of the names of the display objects to load.
     * @param callback a Function that will be called when all the display objects
     *                 are loaded (or were unable to load).
     *                 Signature: <code>function (results :Object) :void</code>.
     *                 results will contain a mapping from name -> EmbeddedSwfLoader, or null.
     * @param useSubDomain if true, classes in a loaded SWF will be added to an
     *                     ApplicationDomain that is a child of the current ApplicationDomain.
     */
    public function getSwfLoaders (
        names :Array, callback :Function, useSubDomain :Boolean = false) :void
    {
        doGetObjects(names, callback, useSubDomain, true);
    }


    // internal name array loader
    protected function doGetObjects (
        names :Array, callback :Function, useSubDomain :Boolean, returnRawLoaders :Boolean) :void
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
        var loadHandler :Function = function (name :String, result :Object) :void {
            // store the result of the load
            dispObjects[name] = result;

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
                doLoadObject(fileName, bytes, loadHandler, useSubDomain, returnRawLoaders);
            }
        }

        // finally, if by some reason there's nothing to load, succeed now
        if (toLoad == 0) {
            callback(dispObjects);
        }
    }

    protected function doLoadObject (
        name :String, bytes :ByteArray, loadHandler :Function,
        useSubDomain :Boolean, returnRawLoaders :Boolean) :void
    {
        var esl :EmbeddedSwfLoader = new EmbeddedSwfLoader(useSubDomain);

        var eslHandler :Function = function (event :Event) :void {
            if (event.type == Event.COMPLETE) {
                loadHandler(name, returnRawLoaders ? esl : esl.getContent());
            } else {
                loadHandler(name, null);
            }
        }

        esl.addEventListener(Event.COMPLETE, eslHandler);
        esl.addEventListener(IOErrorEvent.IO_ERROR, eslHandler);

        esl.load(bytes);
    }

    protected function getFileInternal (name :String, asString :Boolean) :*
    {
        name = validateAccess(name);

        var datum :XML = _metadata..file.(@name == name)[0];
        if (datum == null) {
            return undefined;
        }

        var val :XMLList = datum.@value;
        if (val.length == 0 || val[0] === undefined) {
            return undefined;
        }

        var value :String = String(val[0]);
        trace("Raw value for file '" + name + "' is '" + value + "'");
        if (value == null) {
            return undefined;
        }

        var file :FZipFile = _zip.getFileByName(value);
        return (file == null) ? null : (asString ? file.getContentAsString() : file.content);
    }

    protected function validateAccess (name :String) :String
    {
        if (name == null) {
            throw new ArgumentError("Invalid name: " + name);
        }

        // TODO: we may need to verify that the urlencoding is happening the same
        // way that it is in Java
        return escape(name);
    }

    protected function validateComplete () :void
    {
        if (!isComplete()) {
            throw new IllegalOperationError("DataPack is not loaded.");
        }
    }

    /**
     * Handle some sort of problem loading the datapack.
     */
    protected function handleLoadError (event :ErrorEvent) :void
    {
        dispatchError("Error loading datapack: " + event.text);
    }

    /**
     * Handle some sort of problem parsing datapack.
     */
    protected function handleParseError (event :FZipErrorEvent) :void
    {
        dispatchError("Error parsing datapack: " + event.text);
    }

//    protected function handleFileLoaded (event :FZipEvent) :void
//    {
//        trace("Got file: " + event.file.filename);
//    }

    /**
     * Handle the successful completion of datapack loading.
     */
    protected function handleLoadingComplete (event :Event) :void
    {
        // find the metadata file
        var dataFile :FZipFile = _zip.getFileByName("_data.xml");
        if (dataFile == null) {
            dispatchError("No _data.xml contained in DataPack.");
            return;
        }

        // now try parsing the data
        try {
            // this also can throw an Error if the XML doesn't parse
            _metadata = XML(dataFile.getContentAsString());

        } catch (error :Error) {
            dispatchError("Could not parse datapack: " + error.message);
            return;
        }

        // yay, we're completely loaded!
        dispatchEvent(new Event(Event.COMPLETE));
    }

    protected function dispatchError (message :String) :void
    {
        dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, message));
    }

    protected var _zip :FZip;

    protected var _metadata :XML;
}
}
