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
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.FileFilter;

import mx.containers.HBox;
import mx.containers.VBox;
import mx.controls.Label;
import mx.core.UIComponent;

import com.threerings.flex.CommandButton;

import com.threerings.util.Log;

public class EditProjectDialog extends LightweightCenteredDialog
{
    public function EditProjectDialog (existingProject :File, callback :Function)
    {
        _existingProject = existingProject;
        _saveCallback = callback;
        if (_existingProject != null) {
            var stream :FileStream = new FileStream();
            stream.open(_existingProject, FileMode.READ);
            _projectXml = XML(stream.readUTFBytes(stream.bytesAvailable));
            stream.close();
        } else {
            _projectXml = <platformerproject/>;
        }

        width = 600;
        height = 200;
        title = (_existingProject != null ? "Edit" : "Create") + " Project";
        setStyle("backgroundColor", "white");
    }

    override protected function createChildren () :void
    {
        super.createChildren();

        // Windows use vertical layout by default, but VBox gives us some extra stuff, like padding
        var container :VBox = new VBox();
        container.percentWidth = 100;
        container.percentHeight = 100;
        setStyles(container, -1, 10);
        addChild(container);

        var pieceXmlFile :File = Editor.resolvePath(
            _existingProject != null ? _existingProject.parent : null, 
            String(_projectXml.pieceXml.@path));
        var pieceSwfFile :File = Editor.resolvePath(
            _existingProject != null ? _existingProject.parent : null,
            String(_projectXml.pieceSwf.@path));
        var dynamicsXmlFile :File = Editor.resolvePath(
            _existingProject != null ? _existingProject.parent : null,
            String(_projectXml.dynamicsXml.@path));

        FileRow.findPath = findPath;
        FileRow.findFile = findFile;
        FileRow.createFile = createFile;
        container.addChild(_pieceXmlRow = 
            new FileRow("Piece XML", "xml", true, pieceXmlFile, _existingProject));
        container.addChild(_pieceSwfRow =
            new FileRow("Piece SWF", "swf", false, pieceSwfFile, _existingProject));
        container.addChild(_dynamicsXmlRow = 
            new FileRow("Dynamics XML", "xml", true, dynamicsXmlFile, _existingProject));

        var dialogButtons :HBox = new HBox(); 
        dialogButtons.percentWidth = 100;
        setStyles(dialogButtons, 10, 5);
        var spacer :HBox = new HBox();
        spacer.percentWidth = 100;
        dialogButtons.addChild(spacer);
        dialogButtons.addChild(new CommandButton("Cancel", close));
        dialogButtons.addChild(new CommandButton("Save", handleSave));
        container.addChild(dialogButtons);
    }

    protected function setStyles (component :UIComponent, gap :int, padding :int) :void
    {
        if (gap >= 0) {
            component.setStyle("horizontalGap", gap);
        }

        if (padding >= 0) {
            component.setStyle("paddingTop", padding);
            component.setStyle("paddingBottom", padding);
            component.setStyle("paddingLeft", padding);
            component.setStyle("paddingRight", padding);
        }
    }

    public function handleSave () :void
    {
        if (_pieceXmlRow.file == null || _pieceSwfRow.file == null || 
                _dynamicsXmlRow.file == null) {
            Editor.popError("All files are required");
            return;
        }

        if (!Editor.checkFileSanity(_pieceSwfRow.file, "swf", "Piece SWF")) {
            return;
        }

        if (_pieceXmlRow.create) {
            var pieceXml :XML = <platformer>
                <pieceset/>
            </platformer>;
            var outputString :String = XML_HEADER + pieceXml.toXMLString() + '\n';
            var stream :FileStream = new FileStream();
            stream.open(_pieceXmlRow.file, FileMode.WRITE);
            stream.writeUTFBytes(outputString);
            stream.close();
        }
        if (!Editor.checkFileSanity(_pieceXmlRow.file, "xml", "Piece XML")) {
            return;
        }

        if (_dynamicsXmlRow.create) {
            var dynamicsXml :XML = <dynamics/>;
            outputString = XML_HEADER + dynamicsXml.toXMLString() + '\n';
            stream = new FileStream();
            stream.open(_dynamicsXmlRow.file, FileMode.WRITE);
            stream.writeUTFBytes(outputString);
            stream.close();
        }
        if (!Editor.checkFileSanity(_dynamicsXmlRow.file, "xml", "Dynamics XML")) {
            return;
        }

        if (_existingProject == null) {
            var newFile :File = 
                new File(File.desktopDirectory.nativePath + File.separator + "project.xml");
            newFile.browseForSave("Select new project file location [*.xml]");
            var saver :Function;
            saver = function (event :Event) :void {
                newFile.removeEventListener(Event.SELECT, saver);
                saveAndClose(sanitizeFilename(event.target as File));
            };
            newFile.addEventListener(Event.SELECT, saver);
            fileDialogCloseHandler(newFile);

        } else {
            saveAndClose(_existingProject);
        }
    }

    protected function saveAndClose (file :File) :void
    {
        _projectXml.pieceXml = <pieceXml/>;
        _projectXml.pieceXml.@path = findPath(file, _pieceXmlRow.file);
        _projectXml.pieceSwf = <pieceSwf/>;
        _projectXml.pieceSwf.@path = findPath(file, _pieceSwfRow.file);
        _projectXml.dynamicsXml = <dynamicsXml/>;
        _projectXml.dynamicsXml.@path = findPath(file, _dynamicsXmlRow.file);

        var outputString :String = XML_HEADER + _projectXml.toXMLString() + '\n';
        var stream :FileStream = new FileStream();
        stream.open(file, FileMode.WRITE);
        stream.writeUTFBytes(outputString);
        stream.close();

        close();
        _saveCallback(file);
    }

    /**
     * I can't believe how much Adobe fails at life.  AIR lets you filter file selection by 
     * extension on file selection for open and file selection for upload... but not file selection
     * for save.
     */
    protected function sanitizeFilename (file :File) :File
    {
        var pathRegExp :RegExp = 
            new RegExp("^(.*" + File.separator + ")([^" + File.separator + "]+)$");
        var filePath :String = file.nativePath.replace(pathRegExp, "$1");
        var fileName :String = file.nativePath.replace(pathRegExp, "$2"); 
        fileName = fileName.indexOf(".") < 0 ? fileName : fileName.replace(/^(.*)\.[^\.]*$/, "$1");
        return new File(filePath + fileName + ".xml");
    }

    protected function findFile (desc :String, label :Label, file :File, 
        extension :String, creationFlag :Function) :Function 
    {
        return function () :void {
            file.browseForOpen("Select " + desc + " file...", 
                [new FileFilter(extension + " files", "*." + extension)]);
            var opener :Function;
            opener = function (event :Event) :void {
                label.text = findPath(_existingProject, file);
                // for some reason, this window hides behind the main window after the file
                // selection dialog has popped.
                orderToFront();
                creationFlag(false);
                file.removeEventListener(Event.SELECT, opener);
            };
            file.addEventListener(Event.SELECT, opener);
            fileDialogCloseHandler(file);
        };
    }

    protected function createFile (desc :String, label :Label, file :File, 
        extension :String, creationFlag :Function) :Function
    {
        return function () :void {
            file.browseForSave("Select new " + desc + " file location [*." + extension + "]");
            var creator :Function;
            creator = function (event :Event) :void {
                file = sanitizeFilename(file);
                label.text = findPath(_existingProject, file);
                creationFlag(true);
                file.removeEventListener(Event.SELECT, creator);
            };
            file.addEventListener(Event.SELECT, creator);
            fileDialogCloseHandler(file);
        };
    }

    protected function fileDialogCloseHandler (file :File) :void
    {
        var orderer :Function;
        orderer = function (event :Event) :void {
            file.removeEventListener(Event.SELECT, orderer);
            file.removeEventListener(Event.CLOSE, orderer);
            orderToFront();
        };
        file.addEventListener(Event.SELECT, orderer);
        file.addEventListener(Event.CANCEL, orderer);
    }

    protected function findPath (reference :File, child :File) :String
    {
        var path :String = 
            reference != null ? reference.parent.getRelativePath(child, true) : child.nativePath;
        return path == null ? child.nativePath : path;
    }

    protected var _existingProject :File;
    protected var _projectXml :XML;
    protected var _saveCallback :Function;
    protected var _pieceXmlRow :FileRow;
    protected var _pieceSwfRow :FileRow;
    protected var _dynamicsXmlRow :FileRow;

    protected static const XML_HEADER :String = '<?xml version="1.0" encoding="utf-8"?>\n';
}
}

import flash.filesystem.File;

import mx.containers.HBox;
import mx.controls.Label;

import com.threerings.flex.CommandButton;

import com.whirled.contrib.platformer.editor.air.Editor;

class FileRow extends HBox 
{
    public function FileRow (description :String, extension :String, createOption :Boolean, 
        existingFile :File, projectFile :File)
    {
        _description = description;
        _extension = extension;
        _createOption = createOption;
        _file = existingFile;
        _projectFile = projectFile;
    }

    public static var findPath :Function;
    public static var findFile :Function;
    public static var createFile :Function;

    public function get file () :File
    {
        return _file;
    }

    public function get create () :Boolean
    {
        return _create;
    }

    protected function setCreation (create :Boolean) :void
    {
        _create = create;
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

        addChild(new CommandButton("Find File", 
            findFile(_description, xmlFilePath, _file, _extension, setCreation)));

        if (_createOption) {
            addChild(new CommandButton("Create File", 
                createFile(_description, xmlFilePath, _file, _extension, setCreation)));
        } else {
            var spacer :HBox = new HBox();
            spacer.width = 86;
            addChild(spacer);
        }
    }

    protected var _description :String;
    protected var _extension :String;
    protected var _projectFile :File;
    protected var _file :File;
    protected var _createOption :Boolean;
    protected var _create :Boolean = false;
}
