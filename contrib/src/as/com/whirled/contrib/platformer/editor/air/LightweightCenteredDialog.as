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

import flash.display.NativeWindow;
import flash.display.NativeWindowSystemChrome;
import flash.display.NativeWindowType;
import flash.display.Screen;

import mx.core.Window;

public class LightweightCenteredDialog extends Window
{
    override public function open (openWindowActive :Boolean = true) :void
    {
        maximizable = false;
        minimizable = false;
        resizable = false;
        showStatusBar = false;
        showGripper = false;
        systemChrome = NativeWindowSystemChrome.NONE;
        type = NativeWindowType.LIGHTWEIGHT;

        super.open(openWindowActive);

        nativeWindow.x = Screen.mainScreen.bounds.width / 2 - nativeWindow.width / 2;
        nativeWindow.y = Screen.mainScreen.bounds.height / 2 - nativeWindow.height / 2;
    }
}
}
