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

import flash.events.Event;
import flash.filesystem.File;
import flash.net.FileFilter;

import com.whirled.contrib.EventHandlers;

import com.whirled.contrib.platformer.editor.air.FeedbackDialog;

public /* abstract */ class EditorFile extends File
{
    public static const XML_FILE :int = 1;
    public static const SWF_FILE :int = 2;

    public static function resolvePath (parentDir :File, path :String, description :String, 
        type :int) :EditorFile
    {
        if (path == null || path == "") {
            path = parentDir != null ? parentDir.nativePath : File.desktopDirectory.nativePath;

        } else if (parentDir != null) {
            path = parentDir.resolvePath(path).nativePath;
        }

        switch(type) {
        case XML_FILE:
            return new XmlFile(description, path);

        case SWF_FILE:
            return new SwfFile(description, path);

        default:
            return null;
        }
    }

    public static function findPath (reference :File, child :File) :String
    {
        var path :String = 
            reference != null ? reference.parent.getRelativePath(child, true) : child.nativePath;
        return path == null ? child.nativePath : path;
    }

    public function EditorFile (description :String, extension :String, path :String = null) 
    {
        super(path);
        _description = description;
        _extension = extension;
    }

    public function get editorType () :int
    {
        throw new Error("ABSTRACT");
    }

    override public function get extension () :String
    {
        return _extension;
    }

    public function get description () :String
    {
        return _description;
    }

    public function browseForFile (callback :Function) :void
    {
        browseForOpen("Select " + _description + " file", 
            [new FileFilter(_description, "*." + _extension)]);
        var thisFile :EditorFile = this;
        EventHandlers.registerOneShotCallback(this, Event.SELECT, function () :void {
            callback(thisFile);
        });
    }

    public function createFile (callback :Function) :void
    {
        browseForSave("Select new " + _description + " file location [*." + _extension + "]");
        var thisFile :EditorFile = this;
        EventHandlers.registerOneShotCallback(this, Event.SELECT, function () :void {
            callback(thisFile);
        });
    }

    public function sanitizeFilename () :void
    {
        var pathRegExp :RegExp = 
            new RegExp("^(.*" + File.separator + ")([^" + File.separator + "]+)$");
        var filePath :String = nativePath.replace(pathRegExp, "$1");
        var fileName :String = nativePath.replace(pathRegExp, "$2"); 
        fileName = fileName.indexOf(".") < 0 ? fileName : fileName.replace(/^(.*)\.[^\.]*$/, "$1");
        nativePath = (new File(filePath + fileName + "." + _extension)).nativePath;
    }

    public function checkFileSanity (popErrors :Boolean = true) :Boolean
    {
        var error :String = null;
        if (!exists) {
            error = "The " + _description + " file was not found at " + nativePath + ".";

        } else if (isDirectory || isHidden || isSymbolicLink || isPackage) {
            error = "The " + _description + " file is required to be a regular file.";

        } else if (nativePath.split(".").pop() != _extension) {
            error = "The " + _description + " file is required to have a \"" + _extension + 
                "\" extension.";
        }

        if (popErrors && error != null) {
            FeedbackDialog.popError(error);
        }

        return error == null;
    }

    protected var _description :String;
    protected var _extension :String;
}
}
