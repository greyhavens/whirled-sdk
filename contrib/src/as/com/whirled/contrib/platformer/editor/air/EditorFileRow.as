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

package com.whirled.contrib.platformer.editor.air {

import flash.events.Event;
import flash.filesystem.File;
import flash.net.FileFilter;

import mx.containers.HBox;
import mx.controls.Label;
import mx.core.Window;

import com.threerings.flex.CommandButton;

[Event(name="selectedFile", type="flash.events.Event")];

public class EditorFileRow extends HBox
{
    /** The event that is dispatched when the player selects a new file name */
    public static const SELECTED :String = "selectedFile";

    /**
     * I can't believe how much Adobe fails at life.  AIR lets you filter file selection by 
     * extension on file selection for open and file selection for upload... but not file selection
     * for save.
     */
    public static function sanitizeFilename (file :File) :File
    {
        var pathRegExp :RegExp = 
            new RegExp("^(.*" + File.separator + ")([^" + File.separator + "]+)$");
        var filePath :String = file.nativePath.replace(pathRegExp, "$1");
        var fileName :String = file.nativePath.replace(pathRegExp, "$2"); 
        fileName = fileName.indexOf(".") < 0 ? fileName : fileName.replace(/^(.*)\.[^\.]*$/, "$1");
        return new File(filePath + fileName + ".xml");
    }

    public function EditorFileRow (description :String, extension :String, createOption :Boolean, 
        existingFile :File, projectFile :File, window :Window)
    {
        _description = description;
        _extension = extension;
        _createOption = createOption;
        _file = existingFile;
        _projectFile = projectFile;
        _window = window;
    }

    public function get file () :File
    {
        return _file;
    }

    public function get create () :Boolean
    {
        return _create;
    }

    override protected function createChildren () :void
    {
        super.createChildren();

        percentWidth = 100;
        setStyle("horizontalGap", 10);
        setStyle("paddingTop", 5);
        setStyle("paddingBottom", 5);
        setStyle("paddingLeft", 5);
        setStyle("paddingRight", 5);
        setStyle("borderStyle", "none");

        var fileDesc :Label = new Label();
        fileDesc.text = _description + ":";
        fileDesc.setStyle("fontWeight", "bold");
        addChild(fileDesc);

        var xmlFilePath :Label = new Label();
        xmlFilePath.truncateToFit = true;
        xmlFilePath.text = !Editor.checkFileSanity(_file, _extension, "", false) ?
            "Select file..." : findPath(_projectFile, _file);
        xmlFilePath.percentWidth = 100;
        var pathBox :HBox = new HBox();
        pathBox.setStyle("borderColor", "black");
        pathBox.setStyle("borderThickness", 1);
        pathBox.setStyle("borderStyle", "solid");
        pathBox.percentWidth = 100;
        pathBox.percentHeight = 100;
        pathBox.addChild(xmlFilePath);
        addChild(pathBox);

        addChild(new CommandButton("Find File", findFile(xmlFilePath)));

        if (_createOption) {
            addChild(new CommandButton("Create File", createFile(xmlFilePath)));
        } else {
            var spacer :HBox = new HBox();
            spacer.width = 86;
            addChild(spacer);
        }
    }

    protected function findPath (reference :File, child :File) :String
    {
        var path :String = 
            reference != null ? reference.parent.getRelativePath(child, true) : child.nativePath;
        return path == null ? child.nativePath : path;
    }

    protected function findFile (label :Label) :Function
    {
        return function () :void {
            file.browseForOpen("Select " + _description + " file...", 
                [new FileFilter(_extension + " files", "*." + _extension)]);
            var opener :Function;
            opener = function (event :Event) :void {
                label.text = findPath(_projectFile, _file);
                // for some reason, this window hides behind the main window after the file
                // selection dialog has popped.
                _window.orderToFront();
                _create = false;
                _file.removeEventListener(Event.SELECT, opener);
                dispatchEvent(new Event(SELECTED));
            };
            _file.addEventListener(Event.SELECT, opener);
            fileDialogCloseHandler(_file);
        };
    }

    protected function createFile (label :Label) :Function
    {
        return function () :void {
            file.browseForSave(
                "Select new " + _description + " file location [*." + _extension + "]");
            var creator :Function;
            creator = function (event :Event) :void {
                _file.removeEventListener(Event.SELECT, creator);
                _file = sanitizeFilename(_file);
                label.text = findPath(_projectFile, _file);
                _create = true;
                dispatchEvent(new Event(SELECTED));
            };
            _file.addEventListener(Event.SELECT, creator);
            fileDialogCloseHandler(_file);
        };
    }

    protected function fileDialogCloseHandler (file :File) :void
    {
        var orderer :Function;
        orderer = function (event :Event) :void {
            file.removeEventListener(Event.SELECT, orderer);
            file.removeEventListener(Event.CLOSE, orderer);
            _window.orderToFront();
        };
        file.addEventListener(Event.SELECT, orderer);
        file.addEventListener(Event.CANCEL, orderer);
    }

    protected var _description :String;
    protected var _extension :String;
    protected var _projectFile :File;
    protected var _file :File;
    protected var _createOption :Boolean;
    protected var _create :Boolean = false;
    protected var _window :Window;
}
}
