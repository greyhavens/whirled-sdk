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

package com.whirled.contrib.platformer.piece {

import com.whirled.contrib.platformer.PlatformerContext;
import com.whirled.contrib.platformer.sound.SoundEffect;

/**
 * A simple dynamic that changes it's image when hovered.
 */
public class Hover extends RectDynamic
{
    public var hovered :Boolean = false;
    public var hoverSoundEffect :SoundEffect;

    public function Hover (insxml :XML = null)
    {
        super(insxml);
        if (insxml != null) {
            height = insxml.@height;
            width = insxml.@width;
            sprite = insxml.@sprite;
            if (insxml.hasOwnProperty("@hoverSoundEffect")) {
                hoverSoundEffect = PlatformerContext.getSoundEffect(insxml.@hoverSoundEffect);
            }
        }
        inter = Dynamic.ENEMY;
    }

    override public function xmlInstance () :XML
    {
        var xml :XML = super.xmlInstance();
        xml.@height = height;
        xml.@width = width;
        xml.@sprite = sprite;
        if (hoverSoundEffect != null) {
            xml.@hoverSoundEffect = hoverSoundEffect;
        }
        return xml;
    }

    override public function ownerType () :int
    {
        return OWN_ALL;
    }
}
}
