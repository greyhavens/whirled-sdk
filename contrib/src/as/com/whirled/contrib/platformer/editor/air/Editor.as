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
import flash.utils.ByteArray;

import mx.collections.ArrayCollection;
import mx.containers.TabNavigator;
import mx.containers.VBox;
import mx.controls.FlexNativeMenu;
import mx.controls.Label;
import mx.core.WindowedApplication;
import mx.events.FlexNativeMenuEvent;

import com.whirled.contrib.platformer.display.PieceSpriteFactory;
import com.whirled.contrib.platformer.editor.PieceEditView;
import com.whirled.contrib.platformer.piece.PieceFactory;

/**
 * A class to encapsulate editor functionality with easy file read/write access and AIR supplied
 * native OS look and feel.
 *
 * @playerversion AIR 1.1
 */
public class Editor extends TabNavigator
{
    public static function checkFileSanity (file :File, extension :String, 
        description :String, popErrors :Boolean = true) :Boolean
    {
        if (!file.exists) {
            if (popErrors) {
                popError("The " + description + " file was not found at " + file.nativePath + ".");
            }
            return false;

        } else if (file.isDirectory || file.isHidden || file.isSymbolicLink || file.isPackage) {
            if (popErrors) {
                popError("The " + description + " file is required to be a regular file.");
            }
            return false;

        } else if (file.nativePath.split(".").pop() != extension) {
            if (popErrors) {
                popError("The " + description + " file is required to have a \"" + extension + 
                    "\" extension.");
            }
            return false;
        }

        return true;
    }

    public static function popError (error :String) :void
    {
        (new FeedbackDialog(error, true)).openCentered(_window.nativeWindow);
    }

    public static function popFeedback (feedback :String) :void
    {
        (new FeedbackDialog(feedback)).openCentered(_window.nativeWindow);
    }

    public static function resolvePath (parentDirectory :File, path :String) :File
    {
        if (path == null || path == "") {
            return parentDirectory != null ? parentDirectory.clone() : 
                File.desktopDirectory.clone();
        }

        if (parentDirectory != null) {
            return parentDirectory.resolvePath(path);
        }

        return new File(path);
    }

    public static function findPath (reference :File, child :File) :String
    {
        var path :String = 
            reference != null ? reference.parent.getRelativePath(child, true) : child.nativePath;
        return path == null ? child.nativePath : path;
    }

    public static function writeXmlFile (file :File, xml :XML) :void
    {
        var outputString :String = XML_HEADER + xml.toXMLString() + '\n';
        var stream :FileStream = new FileStream();
        stream.open(file, FileMode.WRITE);
        stream.writeUTFBytes(outputString);
        stream.close();
    }

    public static function readXmlFile (file :File) :XML
    {
        var stream :FileStream = new FileStream();
        stream.open(file, FileMode.READ);
        var xml :XML = XML(stream.readUTFBytes(stream.bytesAvailable));
        stream.close();
        return xml;
    }

    public function Editor ()
    {
        percentWidth = 100;
        percentHeight = 100;
    }

    /**
     * By default, this Editor will use PieceSpriteFactory.init.  If you wish to customize the 
     * sprite factory loading procedure, you can pass a function in here of the following signature,
     * and it will be called instead:
     *
     * function (sources :Array, onReady :Function) :void
     */
    public function setPieceSpriteFactoryClass (initFunc :Function) :void
    {
        _spriteFactoryInit = initFunc;
    }

    override protected function createChildren () :void
    {
        super.createChildren();

        _window = parent as WindowedApplication;
        _menuItems = new ArrayCollection([
            {label: FILE_MENU, children: [
                {label: CREATE_PROJECT},
                {label: LOAD_PROJECT},
                {type: "separator"},
                {label: QUIT}]}]);
        _projectMenu = 
            {label: PROJECT_MENU, children: [
                {label: EDIT_PROJECT},
                {label: SAVE_PIECES},
                {type: "separator"},
                {label: CLOSE_PROJECT}]};
        _levelMenu = 
            {label: LEVEL_MENU, children: [
                {type: "separator"},
                {label: ADD_LEVEL}]};

        var menu :FlexNativeMenu = new FlexNativeMenu();
        menu.dataProvider = _menuItems;
        menu.addEventListener(FlexNativeMenuEvent.ITEM_CLICK, menuItemClicked);
        _window.menu = menu;
    }

    protected function menuItemClicked (event :FlexNativeMenuEvent) :void
    {
        if (event.label == QUIT) {
            closeCurrentProject();
            _window.close();
        } else if (event.label == CREATE_PROJECT) {
            editProject(true);
        } else if (event.label == CLOSE_PROJECT) {
            closeCurrentProject();
        } else if (event.label == LOAD_PROJECT) {
            loadProject();
        } else if (event.label == EDIT_PROJECT) {
            editProject(false);
        } else if (event.label == SAVE_PIECES) {
            savePieceFile();
        } else if (event.label == ADD_LEVEL) {
            addLevel();
        }
    }

    protected function closeCurrentProject () :void
    {
        var idx :int = _menuItems.getItemIndex(_projectMenu);
        if (idx >= 0) {
            _menuItems.removeItemAt(idx);
        }

        idx = _menuItems.getItemIndex(_levelMenu);
        if (idx >= 0) {
            _menuItems.removeItemAt(idx);
        }

        _projectFile = null;

        while (numChildren > 0) {
            removeChildAt(0);
        }
    }

    protected function editProject (createNew :Boolean) :void
    {
        if (createNew && _projectFile != null) {
            closeCurrentProject();
        }

        (new EditProjectDialog(_projectFile, loadProject)).openCentered(_window.nativeWindow);
    }

    protected function loadProject (file :File = null) :void
    {
        if (_projectFile != null) {
            closeCurrentProject();
        }

        // if we're not given a file, pop a dialog for one.
        if (file == null) {
            var newFile :File = new File(File.desktopDirectory.nativePath);
            newFile.browseForOpen("Select project file", [new FileFilter("Project XML", "*.xml")]);
            newFile.addEventListener(Event.SELECT, function (event :Event) :void {
                loadProject(event.target as File);
            });
            return;
        }

        if (!checkFileSanity(file, "xml", "project")) {
            return;
        }

        if (_menuItems.getItemIndex(_projectMenu) < 0) {
            _menuItems.addItem(_projectMenu);
            _menuItems.addItem(_levelMenu);
        }

        var projectXml :XML = readXmlFile(_projectFile = file);
        addPieceEditor(resolvePath(_projectFile.parent, String(projectXml.pieceXml.@path)),
            resolvePath(_projectFile.parent, String(projectXml.pieceSwf.@path)));
    }

    protected function addPieceEditor (xmlFile :File, swfFile :File) :void
    {
        if (!checkFileSanity(xmlFile, "xml", "Pieces XML") || 
            !checkFileSanity(swfFile, "swf", "Pieces SWF")) {
            closeCurrentProject();
            return;
        }

        var piecesXml :XML = readXmlFile(xmlFile);
        var bytes :ByteArray = new ByteArray();
        var stream :FileStream = new FileStream();
        stream.open(swfFile, FileMode.READ);
        stream.readBytes(bytes, 0, stream.bytesAvailable);
        stream.close();
        _spriteFactoryInit([bytes], function () :void {
            _pieceEditView = new PieceEditView(new PieceFactory(piecesXml));
            _pieceEditView.label = "Pieces";
            addChild(_pieceEditView);
        });
    }

    protected function addLevel () :void
    {
        (new AddLevelDialog(_projectFile, addLevelEditor)).openCentered(_window.nativeWindow);
    }

    protected function addLevelEditor (levelFile :File, addToLevel :Boolean = true) :Boolean
    {
        if (!checkFileSanity(levelFile, "xml", "Level XML")) {
            return false;
        }

        var levelXml :XML = readXmlFile(levelFile);
        if (addToLevel) {
            var projectXml :XML = readXmlFile(_projectFile); 
            var levelPath :String = findPath(_projectFile, levelFile);
            if (projectXml.level.(@path == levelPath).length() != 0) {
                popError("That level has already been added to this project");
                return false;
            }

            var levelName :String = String(levelXml.board.@name);
            if (projectXml.level.(@name == levelName).length() != 0) {
                popError("A level of that name has already been added to this project");
                return false;
            }

            var level :XML = <level/>;
            level.@path = levelPath;
            level.@name = levelName;
            projectXml.level += level;
            writeXmlFile(_projectFile, projectXml);
        }

//        var stream :FileStream = new FileStream();
//        stream.open(xmlFile, FileMode.READ);
//        var piecesXml :XML = XML(stream.readUTFBytes(stream.bytesAvailable));
//        stream.close();
//
//        var bytes :ByteArray = new ByteArray();
//        stream = new FileStream();
//        stream.open(swfFile, FileMode.READ);
//        stream.readBytes(bytes, 0, stream.bytesAvailable);
//        stream.close();
//        _spriteFactoryInit([bytes], function () :void {
//            _pieceEditView = new PieceEditView(new PieceFactory(piecesXml.copy()));
//            _pieceEditView.label = "Pieces";
//            addChild(_pieceEditView);
//        });

        return true;
    }

    protected function savePieceFile () :void
    {
        var projectXml :XML = readXmlFile(_projectFile);
        var file :File = resolvePath(_projectFile.parent, String(projectXml.pieceXml.@path));
        if (!checkFileSanity(file, "xml", "Piece XML")) {
            return;
        }

        writeXmlFile(file, _pieceEditView.getXML());
        popFeedback("Piece XML file saved successfully.");
    }

    protected var _menuItems :ArrayCollection;
    protected var _projectMenu :Object;
    protected var _levelMenu :Object;
    protected var _projectFile :File;
    protected var _spriteFactoryInit :Function = PieceSpriteFactory.init;
    protected var _pieceEditView :PieceEditView;

    // there will only ever be one instance of this class in the AIR application runtime.
    protected static var _window :WindowedApplication;

    protected static const FILE_MENU :String = "File";
    protected static const PROJECT_MENU :String = "Project";
    protected static const LEVEL_MENU :String = "Levels";

    protected static const QUIT :String = "Quit";
    protected static const LOAD_PROJECT :String = "Load Project";
    protected static const CREATE_PROJECT :String = "Create Project";
    protected static const CLOSE_PROJECT :String = "Close";
    protected static const EDIT_PROJECT :String = "Edit Project";
    protected static const SAVE_PIECES :String = "Save Piece File";
    protected static const ADD_LEVEL :String = "Add Level";

    protected static const XML_HEADER :String = '<?xml version="1.0" encoding="utf-8"?>\n';
}
}
