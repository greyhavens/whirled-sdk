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

package com.whirled.contrib.platformer.client {

import flash.display.Sprite;
import flash.events.Event;

import com.whirled.contrib.platformer.PlatformerController;
import com.whirled.contrib.platformer.PlatformerContext;

public class ClientPlatformerController extends PlatformerController
{
    public function ClientPlatformerController (source :Sprite)
    {
        super(source);

        _source = source;

        _source.addEventListener(Event.UNLOAD, handleUnload);
        _source.root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);

        if (PlatformerContext.gctrl.isConnected()) {
            ClientPlatformerContext.keyboard = new KeyboardController();
            ClientPlatformerContext.keyboard.init(PlatformerContext.gctrl.local);
        }
    }

    protected function handleUnload (...ignored) :void
    {
        shutdown();
        ClientPlatformerContext.keyboard.shutdown();
        _source.removeEventListener(Event.UNLOAD, handleUnload);
        _source.root.loaderInfo.removeEventListener(Event.UNLOAD, handleUnload);
    }

    protected var _source :Sprite;
}
}
