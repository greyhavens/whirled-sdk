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

package com.whirled.contrib.avrg.probe {

import flash.display.DisplayObject;
import flash.display.Sprite;

/**
 * Displays a sequence of buttons along the top and makes a different child visible in the central
 * part when each button is pressed.
 */
public class TabPanel extends Sprite
{
    /**
     * Adds a new tab.
     * @param name identifies the tab for later selection
     * @param button the button to place in the top row that will select the contents when pressed
     * @param contents the object to show when the button is pressed
     */
    public function addTab (
        name :String, 
        button :Button, 
        contents :DisplayObject) :void
    {
        var tab :Tab = new Tab();
        tab.name = name;
        tab.button = button;
        tab.contents = contents;

        var rhs :int = 0;
        if (_tabs.length > 0) {
            var lastButt :Button = _tabs[_tabs.length - 1].button;
            rhs = lastButt.x + lastButt.width + 5;
        }
        _tabs.push(tab);
        button.x = rhs;
        contents.visible = false;
        contents.y = 20;
        button.addEventListener(ButtonEvent.CLICK, handleButtonClick);
        addChild(button);
        addChild(contents);
    }

    /**
     * Selects a tab by name.
     */
    public function selectTab (name :String) :void
    {
        for each (var t :Tab in _tabs) {
            if (t.name == name) {
                if (_selected != t) {
                    if (_selected != null) {
                        _selected.contents.visible = false;
                        _selected.button.border = false;
                    }
                    t.contents.visible = true;
                    t.button.border = true;
                    _selected = t;
                    return;
                }
            }
        }
    }

    protected function handleButtonClick (event :ButtonEvent) :void
    {
        for each (var t :Tab in _tabs) {
            if (t.button == event.target) {
                selectTab(t.name);
                return;
            }
        }
    }
  
    protected var _selected :Tab;
    protected var _tabs :Array = [];
}

}


import flash.display.DisplayObject;
import com.whirled.contrib.avrg.probe.Button;

class Tab
{
    public var name :String;
    public var button :Button;
    public var contents :DisplayObject;
}
