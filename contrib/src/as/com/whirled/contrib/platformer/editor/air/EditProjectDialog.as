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

        _pieceXmlFile = resolvePath(String(_projectXml.pieceXml.@path));
        _pieceSwfFile = resolvePath(String(_projectXml.pieceSwf.@path));

        width = 500;
        height = 180;
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

        var fileRow :HBox = new HBox();
        container.addChild(fileRow);
        fileRow.percentWidth = 100;
        setStyles(fileRow, 10, 5);
        var fileDesc :Label = new Label();
        fileDesc.text = "Piece XML:";
        fileDesc.setStyle("fontWeight", "bold");
        fileRow.addChild(fileDesc);
        var pathBox :HBox = new HBox();
        pathBox.setStyle("borderColor", "black");
        pathBox.setStyle("borderThickness", 1);
        pathBox.setStyle("borderStyle", "solid");
        pathBox.percentWidth = 100;
        pathBox.percentHeight = 100;
        var xmlFilePath :Label = new Label();
        xmlFilePath.text = !Editor.checkFileSanity(_pieceXmlFile, "xml", "", false) ?
            "Select file..." : findPath(_existingProject, _pieceXmlFile);
        xmlFilePath.percentWidth = 100;
        pathBox.addChild(xmlFilePath);
        fileRow.addChild(pathBox);
        fileRow.addChild(new CommandButton("Find File", 
            findFile("Piece XML", xmlFilePath, _pieceXmlFile, "xml")));
        fileRow.addChild(new CommandButton("Create File", createPieceXML(xmlFilePath)));

        fileRow = new HBox();
        container.addChild(fileRow);
        fileRow.percentWidth = 100;
        setStyles(fileRow, 10, 5);
        fileDesc = new Label();
        fileDesc.text = "Piece SWF:";
        fileDesc.setStyle("fontWeight", "bold");
        fileRow.addChild(fileDesc);
        pathBox = new HBox();
        pathBox.setStyle("borderColor", "black");
        pathBox.setStyle("borderThickness", 1);
        pathBox.setStyle("borderStyle", "solid");
        pathBox.percentWidth = 100;
        pathBox.percentHeight = 100;
        var swfFilePath :Label = new Label();
        swfFilePath.text = !Editor.checkFileSanity(_pieceSwfFile, "swf", "", false) ?
            "Select file..." : findPath(_existingProject, _pieceSwfFile);
        swfFilePath.percentWidth = 100;
        pathBox.addChild(swfFilePath);
        fileRow.addChild(pathBox);
        fileRow.addChild(new CommandButton("Find File", 
            findFile("Piece SWF", swfFilePath, _pieceSwfFile, "swf")));
        var spacer :HBox = new HBox();
        spacer.width = 86;
        fileRow.addChild(spacer);

        var dialogButtons :HBox = new HBox(); 
        dialogButtons.percentWidth = 100;
        setStyles(dialogButtons, 10, 5);
        spacer = new HBox();
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
        if (_pieceXmlFile == null || _pieceSwfFile == null) {
            Editor.popError("Both the piece XML file and the piece SWF file are required");
            return;
        }

        if (!Editor.checkFileSanity(_pieceSwfFile, "swf", "Piece SWF")) {
            return;
        }

        if (_createPieceXml) {
            var pieceXml :XML = <platformer>
                <pieceset/>
            </platformer>;
            var outputString :String = '<?xml verstion="1.0" encoding="utf-8"?>\n';
            outputString += pieceXml.toXMLString() + '\n';
            var stream :FileStream = new FileStream();
            stream.open(_pieceXmlFile, FileMode.WRITE);
            stream.writeUTFBytes(outputString);
            stream.close();
        }
        if (!Editor.checkFileSanity(_pieceXmlFile, "xml", "Piece XML")) {
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
        _projectXml.pieceXml.@path = findPath(file, _pieceXmlFile);
        _projectXml.pieceSwf = <pieceSwf/>;
        _projectXml.pieceSwf.@path = findPath(file, _pieceSwfFile);

        var outputString :String = '<?xml version="1.0" encoding="utf-8"?>\n';
        outputString += _projectXml.toXMLString() + '\n';
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
        extension :String) :Function 
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
                if (file == _pieceXmlFile) {
                    _createPieceXml = false;
                }
                file.removeEventListener(Event.SELECT, opener);
            };
            file.addEventListener(Event.SELECT, opener);
            fileDialogCloseHandler(file);
        };
    }

    protected function createPieceXML (label :Label) :Function
    {
        return function () :void {
            _pieceXmlFile.browseForSave("Select new Piece XML file location [*.xml]");
            var creator :Function;
            creator = function (event :Event) :void {
                _pieceXmlFile = sanitizeFilename(_pieceXmlFile);
                label.text = findPath(_existingProject, _pieceXmlFile);
                _createPieceXml = true;
                _pieceXmlFile.removeEventListener(Event.SELECT, creator);
            };
            _pieceXmlFile.addEventListener(Event.SELECT, creator);
            fileDialogCloseHandler(_pieceXmlFile);
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

    protected function resolvePath (path :String) :File
    {
        if (path == "") {
            return File.desktopDirectory.clone();
        }

        if (_existingProject != null) {
            return _existingProject.parent.resolvePath(path);
        }

        return new File(path);
    }

    protected function findPath (reference :File, child :File) :String
    {
        var path :String = 
            reference != null ? reference.parent.getRelativePath(child, true) : child.nativePath;
        return path == null ? child.nativePath : path;
    }

    protected var _existingProject :File;
    protected var _pieceXmlFile :File;
    protected var _pieceSwfFile :File;
    protected var _projectXml :XML;
    protected var _saveCallback :Function;
    protected var _createPieceXml :Boolean = false;
}
}
