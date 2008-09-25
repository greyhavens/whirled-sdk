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
        (new ErrorDialog(error)).openCentered(_window.nativeWindow);
    }

    public static function resolvePath (parentDirectory :File, path :String) :File
    {
        if (path == "") {
            return File.desktopDirectory.clone();
        }

        if (parentDirectory != null) {
            return parentDirectory.resolvePath(path);
        }

        return new File(path);
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
                {label: LOAD_PROJECT, keyEquivalent: "l", cmdKey: true},
                {type: "separator"},
                {label: QUIT, keyEquivalent: "q", cmdKey: true}]}]);
        _projectMenu = 
            {label: PROJECT_MENU, children: [
                {label: EDIT_PROJECT},
                {type: "separator"},
                {label: CLOSE_PROJECT}]};

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
        }
    }

    protected function closeCurrentProject () :void
    {
        var idx :int = _menuItems.getItemIndex(_projectMenu);
        if (idx >= 0) {
            _menuItems.removeItemAt(idx);
        }

        _projectFile = null;
        _projectXml = null;

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
        }

        var stream :FileStream = new FileStream();
        stream.open(_projectFile = file, FileMode.READ);
        _projectXml = XML(stream.readUTFBytes(stream.bytesAvailable));
        stream.close();

        addPieceEditor(resolvePath(_projectFile.parent, String(_projectXml.pieceXml.@path)),
            resolvePath(_projectFile.parent, String(_projectXml.pieceSwf.@path)));
    }

    protected function addPieceEditor (xmlFile :File, swfFile :File) :void
    {
        var stream :FileStream = new FileStream();
        stream.open(xmlFile, FileMode.READ);
        var piecesXml :XML = XML(stream.readUTFBytes(stream.bytesAvailable));
        stream.close();

        var bytes :ByteArray = new ByteArray();
        stream = new FileStream();
        stream.open(swfFile, FileMode.READ);
        stream.readBytes(bytes, 0, stream.bytesAvailable);
        stream.close();
        _spriteFactoryInit([bytes], function () :void {
            var pieceEditView :PieceEditView = new PieceEditView(new PieceFactory(piecesXml));
            pieceEditView.label = "Pieces";
            addChild(pieceEditView);
        });
    }

    protected var _menuItems :ArrayCollection;
    protected var _projectMenu :Object;
    protected var _projectFile :File;
    protected var _projectXml :XML;

    protected var _spriteFactoryInit :Function = PieceSpriteFactory.init;

    // there will only ever be one instance of this class in the AIR application runtime.
    protected static var _window :WindowedApplication;

    protected static const FILE_MENU :String = "File";
    protected static const PROJECT_MENU :String = "Project";

    protected static const QUIT :String = "Quit";
    protected static const LOAD_PROJECT :String = "Load Project";
    protected static const CREATE_PROJECT :String = "Create Project";
    protected static const CLOSE_PROJECT :String = "Close";
    protected static const EDIT_PROJECT :String = "Edit...";
}
}
