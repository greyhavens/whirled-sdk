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
import flash.utils.ByteArray;

public class SwfFile extends EditorFile
{
    public function SwfFile (description :String, path :String = null) 
    {
        super(description, "swf", path);
    }

    override public function get editorType () :int
    {
        return SWF_FILE;
    }

    public function readBytes () :ByteArray
    {
        var bytes :ByteArray = new ByteArray();
        var stream :FileStream = new FileStream();
        stream.open(this, FileMode.READ);
        stream.readBytes(bytes, 0, stream.bytesAvailable);
        stream.close();
        return bytes;
    }
}
}
