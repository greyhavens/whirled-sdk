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

import com.whirled.contrib.platformer.editor.air.file.EditorFile;
import com.whirled.contrib.platformer.editor.air.file.SwfFile;
import com.whirled.contrib.platformer.editor.air.file.XmlFile;

/**
 * A class to encapsulate editor functionality with easy file read/write access and AIR supplied
 * native OS look and feel.
 *
 * @playerversion AIR 1.1
 */
public class Editor extends TabNavigator
{
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

        (new EditProjectDialog(_projectFile, loadProject)).open();
    }

    protected function loadProject (file :XmlFile = null) :void
    {
        if (_projectFile != null) {
            closeCurrentProject();
        }

        // if we're not given a file, pop a dialog for one.
        if (file == null) {
            var newFile :XmlFile = new XmlFile("Project XML", File.desktopDirectory.nativePath)
            newFile.browseForFile(loadProject);
            return;
        }

        if (!file.checkFileSanity()) {
            return;
        }

        if (_menuItems.getItemIndex(_projectMenu) < 0) {
            _menuItems.addItem(_projectMenu);
            _menuItems.addItem(_levelMenu);
        }

        var projectXml :XML = (_projectFile = file).readXml();
        var pieceXmlFile :XmlFile = EditorFile.resolvePath(_projectFile.parent, 
            String(projectXml.pieceXml.@path), "Piece XML", EditorFile.XML_FILE) as XmlFile;
        var pieceSwfFile :SwfFile = EditorFile.resolvePath(_projectFile.parent,
            String(projectXml.pieceSwf.@path), "Piece SWF", EditorFile.SWF_FILE) as SwfFile;
        addPieceEditor(pieceXmlFile, pieceSwfFile);
    }

    protected function addPieceEditor (xmlFile :XmlFile, swfFile :SwfFile) :void
    {
        if (!xmlFile.checkFileSanity() || !swfFile.checkFileSanity()) {
            closeCurrentProject();
            return;
        }

        var piecesXml :XML = xmlFile.readXml();
        _spriteFactoryInit([swfFile.readBytes()], function () :void {
            _pieceEditView = new PieceEditView(new PieceFactory(piecesXml));
            _pieceEditView.label = "Pieces";
            addChild(_pieceEditView);
        });
    }

    protected function addLevel () :void
    {
        (new AddLevelDialog(_projectFile, addLevelEditor)).open();
    }

    protected function addLevelEditor (levelFile :XmlFile, addToLevel :Boolean = true) :Boolean
    {
        if (!levelFile.checkFileSanity()) {
            return false;
        }

        var levelXml :XML = levelFile.readXml();
        if (addToLevel) {
            var projectXml :XML = _projectFile.readXml();
            var levelPath :String = EditorFile.findPath(_projectFile, levelFile);
            if (projectXml.level.(@path == levelPath).length() != 0) {
                FeedbackDialog.popError("That level has already been added to this project.");
                return false;
            }

            var levelName :String = String(levelXml.board.@name);
            if (projectXml.level.(@name == levelName).length() != 0) {
                FeedbackDialog.popError(
                    "A level of that name has already been added to this project.");
                return false;
            }

            var level :XML = <level/>;
            level.@path = levelPath;
            level.@name = levelName;
            projectXml.level += level;
            _projectFile.writeXml(projectXml);
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
        var projectXml :XML = _projectFile.readXml();
        var pieceFile :XmlFile = EditorFile.resolvePath(_projectFile.parent, 
            String(projectXml.pieceXml.@path), "Piece XML", EditorFile.XML_FILE) as XmlFile;
        if (!pieceFile.checkFileSanity()) {
            return;
        }

        pieceFile.writeXml(_pieceEditView.getXML());
        FeedbackDialog.popFeedback("Piece XML file saved successfully.");
    }

    protected var _menuItems :ArrayCollection;
    protected var _projectMenu :Object;
    protected var _levelMenu :Object;
    protected var _projectFile :XmlFile;
    protected var _spriteFactoryInit :Function = PieceSpriteFactory.init;
    protected var _pieceEditView :PieceEditView;
    protected var _window :WindowedApplication;

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
}
}
