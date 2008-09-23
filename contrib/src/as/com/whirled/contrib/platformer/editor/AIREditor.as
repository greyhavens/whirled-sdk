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

package com.whirled.contrib.platformer.editor {

import flash.filesystem.File;

import mx.core.WindowedApplication;
import mx.containers.VBox;
import mx.controls.FlexNativeMenu;
import mx.events.FlexNativeMenuEvent;

/**
 * A class to encapsulate editor functionality with easy file read/write access and AIR supplied
 * native OS look and feel.
 *
 * @playerversion AIR 1.1
 */
public class AIREditor extends VBox
{
    override protected function createChildren () :void
    {
        super.createChildren();

        _window = parent as WindowedApplication;

        var menu :FlexNativeMenu = new FlexNativeMenu();
        menu.dataProvider = 
            {label: "File", children: [
                {label: LOAD_FILE},
                {type: "separator"},
                {label: CLOSE}]};
        menu.addEventListener(FlexNativeMenuEvent.ITEM_CLICK, menuItemClicked);
        _window.menu = menu;
    }

    protected function menuItemClicked (event :FlexNativeMenuEvent) :void
    {
        if (event.label == CLOSE) {
            _window.close();
        } else if (event.label == LOAD_FILE) {
            (new File()).browseForOpen("Testing File Dialog");
        }
    }

    protected var _window :WindowedApplication;

    protected static const CLOSE :String = "Close";
    protected static const LOAD_FILE :String = "Load File";
}
}
