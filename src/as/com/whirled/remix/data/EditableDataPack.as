//
// $Id$

package com.whirled.remix.data {

import flash.utils.ByteArray;

import nochump.util.zip.ZipEntry;
import nochump.util.zip.ZipOutput;

import com.whirled.DataPack;

public class EditableDataPack extends DataPack
{
    public function EditableDataPack (urlOrByteArrayOrNothing :*)
    {
        // allow blank packs to be created
        if (urlOrByteArrayOrNothing != null) {
            super(urlOrByteArrayOrNothing);
        } else {
            _metadata = <datapack></datapack>;
        }
    }

    public function getDataFields () :Array /* of String */
    {
        var list :XMLList = _metadata..data;
        trace(list);

        var fields :Array = [];
        return fields;
    }

    public function getFileFields (includeContent :Boolean = false) :Array /* of String */
    {
        var list :XMLList = _metadata..file;
        trace(list);

        // TODO
        var fields :Array = [];
        if (!includeContent) {
            var dex :int = fields.indexOf(CONTENT_DATANAME);
            if (dex != -1) {
                fields.splice(dex, 1);
            }
        }
        return fields;
    }

    /**
     * Serialize this pack into a ByteArray suitable for saving.
     */
    public function serialize () :ByteArray
    {
        var outZip :ZipOutput = new ZipOutput();

        // let's write out the metadata first
        var entry :ZipEntry = new ZipEntry(METADATA_FILENAME);
        outZip.putNextEntry(entry);
        outZip.write(stringToBytes(String(_metadata)));
        outZip.closeEntry();

        var names :Array = getFileFields(true);

        for each (var name :String in names) {
            var fileName :String = getFileName(name);
            entry = new ZipEntry(fileName);
            outZip.putNextEntry(entry);
            outZip.write(getFileBytes(fileName));
            outZip.closeEntry();
        }
        outZip.finish();

        return outZip.byteArray;
    }

    override protected function getFileBytes (fileName :String) :ByteArray
    {
        // see if we've got a new file by that name, which takes precedence over an old file
        var bytes :ByteArray = _newFiles[fileName] as ByteArray;
        if (bytes != null) {
            return bytes;

        } else {
            return super.getFileBytes(fileName);
        }
    }

    override protected function validateName (name :String) :void
    {
        switch (name) {
        case CONTENT_DATANAME: // this name is OK here
            break;

        default:
            super.validateName(name);
            break;
        }
    }

    protected function stringToBytes (s :String) :ByteArray
    {
        var ba :ByteArray = new ByteArray();
        ba.writeUTFBytes(s);
        return ba;
    }

//    /** Contains filenames that are in the _zip that should not be written.
//     * Maps: <filename:String> -> true */
//    protected var _omittedFiles :Object = {};

    /** New file data not contained in the _zip.
     * Maps: <filename:String> -> <data:ByteArray> */
    protected var _newFiles :Object = {};
}
}
