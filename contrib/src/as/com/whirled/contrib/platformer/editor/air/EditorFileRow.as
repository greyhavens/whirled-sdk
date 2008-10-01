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
import mx.controls.Label;
import mx.core.Window;

import com.threerings.flex.CommandButton;

import com.whirled.contrib.platformer.editor.air.file.EditorFile;
import com.whirled.contrib.platformer.editor.air.file.XmlFile;

[Event(name="selectedFile", type="flash.events.Event")];

public class EditorFileRow extends HBox
{
    /** The event that is dispatched when the player selects a new file name */
    public static const SELECTED :String = "selectedFile";

    public function EditorFileRow (existingFile :EditorFile, createOption :Boolean, 
        projectFile :XmlFile, window :Window)
    {
        _file = existingFile;
        _createOption = createOption;
        _projectFile = projectFile;
        _window = window;
    }

    public function get file () :EditorFile
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
        fileDesc.text = _file.description + ":";
        fileDesc.setStyle("fontWeight", "bold");
        addChild(fileDesc);

        var xmlFilePath :Label = new Label();
        xmlFilePath.truncateToFit = true;
        xmlFilePath.text = !file.checkFileSanity(false) ?
            "Select file..." : EditorFile.findPath(_projectFile, _file);
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

    protected function findFile (label :Label) :Function
    {
        return function () :void {
            _file.browseForFile(function (file :File) :void {
                label.text = EditorFile.findPath(_projectFile, _file);
                _create = false;
                dispatchEvent(new Event(SELECTED));
            });
            fileDialogCloseHandler(_file);
        };
    }

    protected function createFile (label :Label) :Function
    {
        return function () :void {
            _file.createFile(function (file :File) :void {
                _file.sanitizeFilename();
                label.text = EditorFile.findPath(_projectFile, _file);
                _create = true;
                dispatchEvent(new Event(SELECTED));
            });
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
    protected var _projectFile :XmlFile;
    protected var _file :EditorFile;
    protected var _createOption :Boolean;
    protected var _create :Boolean = false;
    protected var _window :Window;
}
}
