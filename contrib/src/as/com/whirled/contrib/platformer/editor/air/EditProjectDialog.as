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

import mx.containers.HBox;
import mx.containers.VBox;
import mx.core.UIComponent;

import com.threerings.flex.CommandButton;

import com.whirled.contrib.platformer.editor.air.file.EditorFile;
import com.whirled.contrib.platformer.editor.air.file.XmlFile;
import com.whirled.contrib.platformer.editor.air.file.SwfFile;

public class EditProjectDialog extends LightweightCenteredDialog
{
    public function EditProjectDialog (existingProject :XmlFile, callback :Function)
    {
        _existingProject = existingProject;
        _saveCallback = callback;
        if (_existingProject != null) {
            _projectXml = _existingProject.readXml();
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

        var parentDir :File = _existingProject != null ? _existingProject.parent : null;
        var pieceXmlFile :XmlFile = EditorFile.resolvePath(parentDir, 
            String(_projectXml.pieceXml.@path), "Piece XML", EditorFile.XML_FILE) as XmlFile;
        var pieceSwfFile :SwfFile = EditorFile.resolvePath(parentDir,
            String(_projectXml.pieceSwf.@path), "Piece SWF", EditorFile.SWF_FILE) as SwfFile;
        var dynamicsXmlFile :XmlFile = EditorFile.resolvePath(parentDir,
            String(_projectXml.dynamicsXml.@path), "Dynamics XML", EditorFile.XML_FILE) as XmlFile;

        container.addChild(
            _pieceXmlRow = new EditorFileRow(pieceXmlFile, true, _existingProject, this));
        container.addChild(
            _pieceSwfRow = new EditorFileRow(pieceSwfFile, false, _existingProject, this));
        container.addChild(
            _dynamicsXmlRow = new EditorFileRow(dynamicsXmlFile, true, _existingProject, this));

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
        if (!_pieceSwfRow.file.checkFileSanity()) {
            return;
        }

        if (_pieceXmlRow.create) {
            (_pieceXmlRow.file as XmlFile).writeXml(<platformer><pieceset/></platformer>);
        }
        if (!_pieceXmlRow.file.checkFileSanity()) {
            return;
        }

        if (_dynamicsXmlRow.create) {
            (_dynamicsXmlRow.file as XmlFile).writeXml(<dynamics/>);
        }
        if (!_dynamicsXmlRow.file.checkFileSanity()) {
            return;
        }

        if (_existingProject == null) {
            var projectFile :XmlFile = new XmlFile("Project XML", 
                File.desktopDirectory.nativePath + File.separator + "project.xml");
            projectFile.createFile(function (file :XmlFile) :void {
                projectFile.sanitizeFilename();
                saveAndClose(projectFile);
            });
            fileDialogCloseHandler(projectFile);

        } else {
            saveAndClose(_existingProject);
        }
    }

    protected function saveAndClose (file :XmlFile) :void
    {
        _projectXml.pieceXml.@path = EditorFile.findPath(file, _pieceXmlRow.file);
        _projectXml.pieceSwf.@path = EditorFile.findPath(file, _pieceSwfRow.file);
        _projectXml.dynamicsXml.@path = EditorFile.findPath(file, _dynamicsXmlRow.file);

        file.writeXml(_projectXml);
        close();
        _saveCallback(file);
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

    protected var _existingProject :XmlFile;
    protected var _projectXml :XML;
    protected var _saveCallback :Function;
    protected var _pieceXmlRow :EditorFileRow;
    protected var _pieceSwfRow :EditorFileRow;
    protected var _dynamicsXmlRow :EditorFileRow;
}
}
