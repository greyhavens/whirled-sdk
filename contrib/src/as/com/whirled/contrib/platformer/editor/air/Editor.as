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

import flash.filesystem.File;

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
    }

    protected function editProject (createNew :Boolean) :void
    {
        if (_menuItems.getItemIndex(_projectMenu) < 0) {
            _menuItems.addItem(_projectMenu);
        }

        if (createNew && _project != null) {
            closeCurrentProject();
        }

        var dialog :EditProjectDialog = new EditProjectDialog();
        dialog.open();
        dialog.nativeWindow.x = _window.nativeWindow.x + 
            _window.nativeWindow.width / 2 - dialog.nativeWindow.width / 2;
        dialog.nativeWindow.y = _window.nativeWindow.y + 
            _window.nativeWindow.height / 2 - dialog.nativeWindow.height / 2;
    }

    protected function loadProject () :void
    {
        _menuItems.addItem(_projectMenu);
    }

    protected var _window :WindowedApplication;
    protected var _menuItems :ArrayCollection;
    protected var _projectMenu :Object;
    protected var _project :File;

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
