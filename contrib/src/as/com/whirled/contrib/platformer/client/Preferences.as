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

import com.threerings.flash.MathUtil;
import com.threerings.util.Config;

import com.whirled.contrib.platformer.client.ClientPlatformerContext;

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

    public function get backgroundVolume () :Number
    {
        return getValue("backgroundVolume", DEFAULT_BACKGROUND_VOLUME) as Number;
    }

    public function set backgroundVolume (value :Number) :void
    {
        setValue("backgroundVolume",
            MathUtil.clamp(value, MIN_BACKGROUND_VOLUME, MAX_BACKGROUND_VOLUME));
        ClientPlatformerContext.sound.backgroundVolumeModified();
    }

    public function get effectsVolume () :Number
    {
        return getValue("effectsVolume", DEFAULT_EFFECTS_VOLUME) as Number;
    }

    public function set effectsVolume (value :Number) :void
    {
        setValue("effectsVolume", MathUtil.clamp(value, MIN_EFFECTS_VOLUME, MAX_EFFECTS_VOLUME));
    }

    protected static const DEFAULT_BACKGROUND_VOLUME :Number = 0.5;
    protected static const MIN_BACKGROUND_VOLUME :Number = 0.0;
    protected static const MAX_BACKGROUND_VOLUME :Number = 1.0;
    protected static const DEFAULT_EFFECTS_VOLUME :Number = 0.3;
    protected static const MIN_EFFECTS_VOLUME :Number = 0.0;
    protected static const MAX_EFFECTS_VOLUME :Number = 1.0;
}
}
