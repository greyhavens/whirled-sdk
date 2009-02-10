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

import flash.display.StageQuality;
import flash.net.SharedObject;

import com.threerings.util.Config;

public class Preferences extends Config
{
    public function Preferences (path :String)
    {
        super(path);
    }

    public function get stageQuality () :String
    {
        return getValue("stageQuality", StageQuality.HIGH) as String;
    }

    public function set stageQuality (quality :String) :void
    {
        setValue("stageQuality", quality);
    }

    public function get backgroundScrolling () :Boolean
    {
        return getValue("backgroundScrolling", true) as Boolean;
    }

    public function set backgroundScrolling (scroll :Boolean) :void
    {
        setValue("backgroundScrolling", scroll);
    }

    public function get effectLevel () :int
    {
        return getValue("effectLevel", 0) as int;
    }

    public function set effectLevel (level :int) :void
    {
        setValue("effectLevel", level);
    }
}
}
