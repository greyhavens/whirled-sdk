//
// $Id$

package com.whirled {

import flash.errors.IllegalOperationError;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;

import flash.geom.Point;
import flash.geom.Rectangle;

import flash.utils.ByteArray;

import com.threerings.util.Util;

import nochump.util.zip.ZipEntry;
import nochump.util.zip.ZipError;
import nochump.util.zip.ZipFile;

/**
 * Dispatched when the DataPack could not load due to an error.
 *
 * @eventType flash.events.ErrorEvent.ERROR
 */
[Event(name="error", type="flash.events.ErrorEvent")]

/**
 * A DataPack is a bundle of stored goodies for use by your game, avatar, or other whirled
 * creation. In a DataPack can be named data values as well as named files.
 */
public class BaseDataPack extends EventDispatcher
{

    /**
     * Construct a DataPack to be loaded from the specified source.
     * Note that passing a ByteArray will result in a DataPack that is instantly complete.
     *
     * @param bytes a ByteArray containing the raw data.
     */
    public function BaseDataPack (bytes :ByteArray = null)
    {
        if (bytes != null) {
            bytesAvailable(bytes);
        }
    }

    /**
     * Has the loading of the datapack completed?
     */
    public function isComplete () :Boolean
    {
        return (_metadata != null);
    }

    /**
     * TODO
     * @private
     */
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

        return parseValue(datum);
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
        return Util.newXML(getFileAsString(name));
    }

    /**
     * Parse a data value from the specified XML datum.
     *
     * @private
     */
    protected function parseValue (
        datum :XML, valueField :String = "value", typeOverride :String = null) :*
    {
        var str :* = extractStringValue(datum, valueField);
        if (str === undefined) {
            return str;
        }
        var type :String = (typeOverride != null) ? typeOverride : String(datum.@type);
        return parseValueFromString(str, type);
    }

    /**
     * Extract from the datum either a String, null, or undefined.
     */
    protected function extractStringValue (datum :XML, valueField :String = "value") :*
    {
        var val :XMLList = datum.@[valueField];
        if (val.length == 0 || val[0] === undefined) {
            return undefined;
        }

        // TODO: is this extra null check necessary?
        var value :String = String(val[0]);
//        trace("Raw " + valueField + " for data '" + name + "' is '" + value + "'");
        if (value == null) {
            return undefined;
        }
        return value;
    }

    // TODO: detect errors and throw? Maybe only if a validation flag is passed in, and
    // then pass that flag optionally from the remixer... through entry.fromString()
    // from EditableDataPack.
    protected function parseValueFromString (string :String, type :String) :Object
    {
        var bits :Array;
        switch (type) {
        case "String":
            return unescape(string);

        case "Number":
            return parseFloat(string);

        case "Boolean":
            return "true" == string.toLowerCase();

        case "Color":
            return parseInt(string, 16);

        case "Array":
            return string.split(",").map(function (item :String, ... rest) :String {
                return unescape(item);
            });

        case "Point":
            bits = string.split(",");
            return new Point(parseFloat(bits[0]), parseFloat(bits[1]));

        case "Rectangle":
            bits = string.split(",");
            return new Rectangle(parseFloat(bits[0]), parseFloat(bits[1]),
                parseFloat(bits[2]), parseFloat(bits[3]));

        default:
            trace("Unknown resource type: " + type);
            return string;
        }
    }
    /**
     * Locate the data contained within a file with the specified data name.
     *
     * @private
     */
    protected function getFileInternal (name :String, asString :Boolean) :*
    {
        var value :String = getFileName(name);
        if (value == null) {
            return undefined;
        }

        var bytes :ByteArray = getFileBytes(value);
        if (asString && bytes != null) {
            return bytesToString(bytes);

        } else {
            return bytes;
        }
    }

    /**
     * Get the actual bytes in use for the specified filename.
     *
     * @private
     */
    protected function getFileBytes (fileName :String) :ByteArray
    {
        var entry :ZipEntry = _zip.getEntry(fileName);
        if (entry == null) {
            return null;
        }
        return _zip.getInput(entry);
    }

    /**
     * Translate the requested file into the actual filename stored in the zip.
     *
     * @private
     */
    protected function getFileName (name :String) :String
    {
        name = validateAccess(name);

        var datum :XML = _metadata..file.(@name == name)[0];
        if (datum == null) {
            return null;
        }

        return parseValue(datum, "value", "String");
    }

    /**
     * Validate that the everything is ok accessing the specified data name.
     *
     * @private
     */
    protected function validateAccess (name :String) :String
    {
        validateComplete();
        validateName(name);

        // TODO: we may need to verify that the urlencoding is happening the same
        // way that it is in Java
        return escape(name);
    }

    /**
     * Validate that this DataPack has completed loading.
     *
     * @private
     */
    protected function validateComplete () :void
    {
        if (!isComplete()) {
            throw new IllegalOperationError("DataPack is not loaded.");
        }
    }

    /**
     * Validate that the specified data name is legal.
     *
     * @private
     */
    protected function validateName (name :String) :void
    {
        switch (name) {
        case null: // names can't be null
        case CONTENT_DATANAME: // reserved for special all-in-one media
            throw new ArgumentError("Invalid name: " + name);
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
            dispatchError("Unable to read datapack: " + zipError.message);
            return;
        }

        var dataFile :ZipEntry = _zip.getEntry(METADATA_FILENAME);
        if (dataFile == null) {
            dispatchError("No " + METADATA_FILENAME + " contained in DataPack.");
            return;
        }

        var asString :String = bytesToString(_zip.getInput(dataFile));

        // now try parsing the data
        try {
            // this also can throw an Error if the XML doesn't parse
            _metadata = Util.newXML(asString);

        } catch (error :Error) {
            dispatchError("Could not parse datapack: " + error.message);
            return;
        }
    }

    /**
     * Turn the specified ByteArray into a String.
     *
     * @private
     */
    protected function bytesToString (ba :ByteArray) :String
    {
        ba.position = 0;
        return ba.readUTFBytes(ba.bytesAvailable);
    }

    /**
     * Dispatch an error event with the specified message.
     *
     * @private
     */
    protected function dispatchError (message :String) :void
    {
        if (willTrigger(ErrorEvent.ERROR)) {
            dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, message));
        } else {
            trace("Unhandled DataPack load error: " + message);
        }
    }

    /** The contents of the datapack. @private */
    protected var _zip :ZipFile;

    /** The metadata. @private */
    protected var _metadata :XML;

    /** The filename of the metadata file. @private */
    protected static const METADATA_FILENAME :String = "_data.xml";

    /** The data name of the primary media file, used for all-in-one remixable media. @private */
    protected static const CONTENT_DATANAME :String = "_CONTENT";
}
}

