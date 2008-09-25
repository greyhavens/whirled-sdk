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

        _pieceXmlFile = 
            new File(String(_projectXml.pieceXml.@path) != "" ? _projectXml.pieceXml.@path :
                (_existingProject != null ? _existingProject.parent.nativePath : 
                                            File.desktopDirectory.nativePath));
        _pieceSwfFile = 
            new File(String(_projectXml.pieceSwf.@path) != "" ? _projectXml.pieceSwf.@path :
                (_existingProject != null ? _existingProject.parent.nativePath :
                                            File.desktopDirectory.nativePath));

        width = 400;
        height = 180;
        title = (existingProject != null ? "Edit" : "Create") + " Project";
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
        xmlFilePath.text = Editor.checkFileSanity(_pieceXmlFile, "xml", "", false) ?
            _pieceXmlFile.nativePath : "Select file...";
        xmlFilePath.percentWidth = 100;
        pathBox.addChild(xmlFilePath);
        fileRow.addChild(pathBox);
        fileRow.addChild(
            new CommandButton("Find File", findFile(xmlFilePath, _pieceXmlFile, "xml")));

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
        swfFilePath.text = Editor.checkFileSanity(_pieceSwfFile, "swf", "", false) ?
            _pieceSwfFile.nativePath : "Select file...";
        swfFilePath.percentWidth = 100;
        pathBox.addChild(swfFilePath);
        fileRow.addChild(pathBox);
        fileRow.addChild(
            new CommandButton("Find File", findFile(swfFilePath, _pieceSwfFile, "swf")));

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
        if (_existingProject == null) {
            var newFile :File = 
                new File(File.desktopDirectory.nativePath + File.separator + "project.xml");
            newFile.browseForSave("Select new project file location [*.xml]");
            newFile.addEventListener(Event.SELECT, function (event :Event) :void {
                saveAndClose(sanitizeFilename(event.target as File));
            });

        } else {
            saveAndClose(_existingProject);
        }
    }

    protected function saveAndClose (file :File) :void
    {
        if (_pieceXmlFile == null || _pieceSwfFile == null) {
            Editor.popError("Both the piece XML file and the piece SWF file are required");
            return;
        }

        if (!Editor.checkFileSanity(_pieceXmlFile, "xml", "Piece XML") ||
            !Editor.checkFileSanity(_pieceSwfFile, "swf", "Piece SWF")) {
            return;
        }

        // get relative paths from the project file, if possible... otherwise use the absolute 
        // path representation.
        var pieceXmlPath :String = file.getRelativePath(_pieceXmlFile, true);
        pieceXmlPath = pieceXmlPath == null ? _pieceXmlFile.nativePath : pieceXmlPath;
        var pieceSwfPath :String = file.getRelativePath(_pieceSwfFile, true);
        pieceSwfPath = pieceSwfPath == null ? _pieceSwfFile.nativePath : pieceSwfPath;

        _projectXml.pieceXml = <pieceXml/>;
        _projectXml.pieceXml.@path = pieceXmlPath;
        _projectXml.pieceSwf = <pieceSwf/>;
        _projectXml.pieceSwf.@path = pieceSwfPath;

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

    protected function findFile (label :Label, file :File, extension :String) :Function 
    {
        return function () :void {};
    }

    protected var _existingProject :File;
    protected var _pieceXmlFile :File;
    protected var _pieceSwfFile :File;
    protected var _projectXml :XML;
    protected var _saveCallback :Function;
}
}
