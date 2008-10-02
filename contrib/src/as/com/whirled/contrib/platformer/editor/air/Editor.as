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
import flash.net.SharedObject;
import flash.utils.ByteArray;

import mx.collections.ArrayCollection;
import mx.containers.TabNavigator;
import mx.containers.VBox;
import mx.controls.FlexNativeMenu;
import mx.controls.Label;
import mx.core.WindowedApplication;
import mx.events.FlexNativeMenuEvent;

import com.threerings.util.HashMap;
import com.threerings.util.Log;

import com.whirled.contrib.platformer.display.Metrics;
import com.whirled.contrib.platformer.display.PieceSpriteFactory;
import com.whirled.contrib.platformer.editor.EditView;
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

        var loader :Function;
        loader = function () :void {
            if (!Metrics.INITIALIZED) {
                callLater(loader);
                return;
            }

            var localSo :SharedObject = SharedObject.getLocal(EDITOR_SHARED_OBJECT);
            if (localSo.data[PROJECT_FILE_PROP] !== undefined) {
                var projectFile :XmlFile = EditorFile.resolvePath(new File(), 
                    localSo.data[PROJECT_FILE_PROP], "Project XML", EditorFile.XML_FILE) as XmlFile;
                if (!projectFile.checkFileSanity(false)) {
                    FeedbackDialog.popError(
                        "Unable to open last open project:\n" + localSo.data[PROJECT_FILE_PROP]);
                } else {
                    loadProject(projectFile);
                }
            }
        };
        loader();
    }

    protected function menuItemClicked (event :FlexNativeMenuEvent) :void
    {
        switch (event.label) {
        case QUIT: 
            closeCurrentProject();
            _window.close();
            break;
        
        case CREATE_PROJECT: editProject(true); break;
        case CLOSE_PROJECT: closeCurrentProject(); break;
        case LOAD_PROJECT: loadProject(); break;
        case EDIT_PROJECT: editProject(false); break;
        case SAVE_PIECES: savePieceFile(); break;
        case ADD_LEVEL: addLevel(); break;
        case OPEN_LEVEL: addLevelEditor(getLevelXmlFile(findLevel(event.item)), false); break;
        case SAVE_LEVEL: saveLevel(findLevel(event.item)); break;
        case CLOSE_LEVEL: closeLevel(findLevel(event.item)); break;
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
        var levels :Array = [];
        for each (var level :XML in projectXml.level) {
            levels.push(String(level.@name));
        }
        addLevelsToMenu(levels);

        var pieceXmlFile :XmlFile = EditorFile.resolvePath(_projectFile.parent, 
            String(projectXml.pieceXml.@path), "Piece XML", EditorFile.XML_FILE) as XmlFile;
        var pieceSwfFile :SwfFile = EditorFile.resolvePath(_projectFile.parent,
            String(projectXml.pieceSwf.@path), "Piece SWF", EditorFile.SWF_FILE) as SwfFile;
        addPieceEditor(pieceXmlFile, pieceSwfFile);

        var localSo :SharedObject = SharedObject.getLocal(EDITOR_SHARED_OBJECT);
        localSo.data[PROJECT_FILE_PROP] = _projectFile.nativePath; 
    }

    protected function addPieceEditor (xmlFile :XmlFile, swfFile :SwfFile) :void
    {
        if (!xmlFile.checkFileSanity() || !swfFile.checkFileSanity()) {
            closeCurrentProject();
            log.warning("closed project due to insanity in project files [" + 
                xmlFile.nativePath + ", " + swfFile.nativePath + "]");
            return;
        }

        var piecesXml :XML = xmlFile.readXml();
        _spriteFactoryInit([swfFile.readBytes()], function () :void {
            _pieceEditView = new PieceEditView(new PieceFactory(piecesXml));
            _pieceEditView.label = "Pieces";
            addChild(_pieceEditView);
        });
    }

    protected function addLevel (name :String = null) :void
    {
        (new AddLevelDialog(_projectFile, addLevelEditor)).open();
    }

    protected function addLevelEditor (levelFile :XmlFile, addToLevel :Boolean = true) :Boolean
    {
        if (!levelFile.checkFileSanity()) {
            return false;
        }

        var levelXml :XML = levelFile.readXml();
        var levelName :String = String(levelXml.board.@name);
        var projectXml :XML = _projectFile.readXml();
        if (addToLevel) {
            var levelPath :String = EditorFile.findPath(_projectFile, levelFile);
            if (projectXml.level.(@path == levelPath).length() != 0) {
                FeedbackDialog.popError("That level has already been added to this project.");
                return false;
            }

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

            addLevelsToMenu(levelName);

            FeedbackDialog.popFeedback(
                "Level has been added to the project, and the project file has been saved.");
        }

        if (_openLevels.containsKey(levelName)) {
            // shouldn't be possible... freak out passively.
            log.warning("asked to open already open level [" + levelName + ", " + addToLevel + "]");
            return true;
        }

        // TODO: this should probably be using the same PieceFactory instance as the 
        // PieceEditView...
        var piecesXml :XML = getProjectXmlFile(projectXml.pieceXml.@path).readXml();
        var dynamicsXml :XML = getProjectXmlFile(projectXml.dynamicsXml.@path).readXml();
        var editView :EditView = new EditView(new PieceFactory(piecesXml), dynamicsXml, levelXml);
        editView.label = levelName.replace("_", " ");
        addChild(editView);
        _openLevels.put(levelName, {editor: editView, file: levelFile});
        var values :Object = {};
        values[OPEN_LEVEL] = false;
        values[CLOSE_LEVEL] = true;
        values[SAVE_LEVEL] = true;
        setLevelMenuItemsEnabled(levelName, values);

        selectedIndex = numChildren - 1;

        return true;
    }

    protected function getProjectXmlFile (path :String) :XmlFile
    {
        return EditorFile.resolvePath(
            _projectFile.parent, path, "", EditorFile.XML_FILE) as XmlFile;
    }

    protected function getLevelXmlFile (levelName :String) :XmlFile
    {
        return getProjectXmlFile(_projectFile.readXml().level.(@name == levelName)[0].@path);
    }

    protected function closeLevel (levelName :String) :void
    {
        // TODO: prompt to save - requires a ConfirmationDialog
        var level :Object = _openLevels.remove(levelName);
        if (level == null) {
            log.warning("level not found to close [" + levelName + "]");
            return;
        }

        removeChild(level.editor);
        var values :Object = {};
        values[OPEN_LEVEL] = true;
        values[CLOSE_LEVEL] = false;
        values[SAVE_LEVEL] = false;
        setLevelMenuItemsEnabled(levelName, values);
    }

    protected function saveLevel (levelName :String) :void
    {
        var level :Object = _openLevels.get(levelName);
        if (level == null) {
            log.warning("level not found to save [" + levelName + "]");
            return;
        }

        (level.file as XmlFile).writeXml((level.editor as EditView).getXML()); 
        FeedbackDialog.popFeedback(levelName + "'s level file has been saved."); 
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

    protected function addLevelsToMenu (levels :*) :void
    {
        var adder :Function = function (name :String) :void {
            name = name.replace("_", " ");
            _levelMenu.children.unshift({
                label: name,
                children: [
                    {label: OPEN_LEVEL, enabled: true},
                    {label: SAVE_LEVEL, enabled: false},
                    {type: "separator"},
                    {label: CLOSE_LEVEL, enabled: false}
                ]
            });
        };

        if (levels is String) {
            adder(levels as String);
        } else {
            for each (var name :String in levels) {
                adder(name);
            }
        }
        _menuItems.itemUpdated(_levelMenu);
    }

    protected function findLevel (menuObject :Object) :String
    {
        for each (var level :Object in _levelMenu.children) {
            if (level.children != null && level.children.indexOf(menuObject) >= 0) {
                return level.label.replace(" ", "_");
            }
        }
        return null;
    }

    protected function setLevelMenuItemsEnabled (levelName :String, values :Object) :void
    {
        levelName = levelName.replace("_", " ");
        for each (var level :Object in _levelMenu.children) {
            if (level.label == levelName) {
                for each (var item :Object in level.children) {
                    if (values[item.label] !== undefined) {
                        item.enabled = values[item.label];
                    }
                }
                _menuItems.itemUpdated(_levelMenu);
                return;
            }
        }
    }

    protected var _menuItems :ArrayCollection;
    protected var _projectMenu :Object;
    protected var _levelMenu :Object;
    protected var _projectFile :XmlFile;
    protected var _spriteFactoryInit :Function = PieceSpriteFactory.init;
    protected var _pieceEditView :PieceEditView;
    protected var _window :WindowedApplication;
    protected var _openLevels :HashMap = new HashMap();

    protected static const log :Log = Log.getLog(Editor);

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
    protected static const OPEN_LEVEL :String = "Open Level";
    protected static const CLOSE_LEVEL :String = "Close Level";
    protected static const SAVE_LEVEL :String = "Save Level";

    protected static const EDITOR_SHARED_OBJECT :String = "PlatformerEditor";
    protected static const PROJECT_FILE_PROP :String = "projectFile";
}
}
