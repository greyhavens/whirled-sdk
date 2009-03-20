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

package com.whirled.contrib.platformer.game {

import com.threerings.util.RandomUtil;

import com.whirled.contrib.platformer.PlatformerContext;

public class BackgroundMusicAction extends EventAction
{
    public function BackgroundMusicAction (gctrl :GameController, xml :XML)
    {
        super(gctrl, xml);

        _track = String(xml.@track).split(",");

        if (xml.hasOwnProperty("@crossfade")) {
            _crossfade = xml.@crossfade == "true";
        }
        if (xml.hasOwnProperty("@loop")) {
            _loop = xml.@loop == "true";
        }
    }

    override public function run () :void
    {
        PlatformerContext.platformer.startBackgroundMusic(
            RandomUtil.pickRandom(_track) as String, _crossfade, _loop);
    }

    protected var _track :Array;
    protected var _crossfade :Boolean = true;
    protected var _loop :Boolean = true;
}
}
