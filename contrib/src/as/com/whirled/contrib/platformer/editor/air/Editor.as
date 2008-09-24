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

import mx.collections.ArrayCollection;
import mx.containers.VBox;
import mx.controls.FlexNativeMenu;
import mx.core.WindowedApplication;
import mx.events.FlexNativeMenuEvent;

/**
 * A class to encapsulate editor functionality with easy file read/write access and AIR supplied
 * native OS look and feel.
 *
 * @playerversion AIR 1.1
 */
public class Editor extends VBox
{
    override protected function createChildren () :void
    {
        super.createChildren();

        _window = parent as WindowedApplication;
        _menuItems = new ArrayCollection([
            {label: APP_MENU, children: [
                {label: QUIT, keyEquivalent: "q", cmdKey: true}]},
            {label: FILE_MENU, children: [
                {label: CREATE_PROJECT},
                {label: LOAD_PROJECT}]}]);
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

        // do some sanity checking on the project file.
        if (file.isDirectory || file.isHidden || file.isSymbolicLink || file.isPackage) {
            popError("The project file is required to be a regular XML file.");
            return;

        } else if (file.nativePath.split(".").pop() != "xml") {
            popError("The project file is required to have a \".xml\" extension.");
            return;
        }

        if (_menuItems.getItemIndex(_projectMenu) < 0) {
            _menuItems.addItem(_projectMenu);
        }

        _projectFile = file;
    }

    protected function popError (error :String) :void
    {
        (new ErrorDialog(error)).openCentered(_window.nativeWindow);
    }

    protected var _window :WindowedApplication;
    protected var _menuItems :ArrayCollection;
    protected var _projectMenu :Object;
    protected var _projectFile :File;

    protected static const APP_MENU :String = "FancyPants Golf Editor";
    protected static const FILE_MENU :String = "File";
    protected static const PROJECT_MENU :String = "Project";

    protected static const QUIT :String = "Quit";
    protected static const LOAD_PROJECT :String = "Load Project";
    protected static const CREATE_PROJECT :String = "Create Project";
    protected static const CLOSE_PROJECT :String = "Close";
    protected static const EDIT_PROJECT :String = "Edit...";
}
}
