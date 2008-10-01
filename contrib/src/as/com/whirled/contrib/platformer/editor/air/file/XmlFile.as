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

package com.whirled.contrib.platformer.editor.air.file {

import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

public class XmlFile extends EditorFile
{
    public function XmlFile (description :String, path :String = null) 
    {
        super(description, "xml", path);
    }

    override public function get editorType () :int
    {
        return XML_FILE;
    }

    public function readXml () :XML
    {
        var stream :FileStream = new FileStream();
        stream.open(this, FileMode.READ);
        var xml :XML = XML(stream.readUTFBytes(stream.bytesAvailable));
        stream.close();
        return xml;
    }

    public function writeXml (xml :XML) :void
    {
        var outputString :String = XML_HEADER + xml.toXMLString() + '\n';
        var stream :FileStream = new FileStream();
        stream.open(this, FileMode.WRITE);
        stream.writeUTFBytes(outputString);
        stream.close();
    }

    protected static const XML_HEADER :String = '<?xml version="1.0" encoding="utf-8"?>\n';
}
}
