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

import mx.core.Window;

public class LightweightCenteredDialog extends Window
{
    public function openCentered (parentWindow :NativeWindow) :void
    {
        maximizable = false;
        minimizable = false;
        resizable = false;
        systemChrome = NativeWindowSystemChrome.NONE;
        type = NativeWindowType.LIGHTWEIGHT;

        open();
        nativeWindow.x = parentWindow.x + parentWindow.width / 2 - nativeWindow.width / 2;
        nativeWindow.y = parentWindow.y + parentWindow.height / 2 - nativeWindow.height / 2;
    }
}
}
