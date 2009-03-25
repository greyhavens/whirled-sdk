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

import flash.utils.ByteArray;

import com.whirled.contrib.platformer.PlatformerContext;
import com.whirled.contrib.platformer.sound.SoundEffect;

/**
 * A simple dynamic that changes it's image when hovered.
 */
public class Hover extends RectDynamic
{
    public static const U_HOVERED :int = 1 << (DYN_COUNT + 1);
    public static const HOVER_COUNT :int = DYN_COUNT + 1;

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

    public function get hovered () :Boolean
    {
        return _hovered;
    }

    public function set hovered (hovered :Boolean) :void
    {
        if (_hovered != hovered) {
            _hovered = hovered;
            updateState |= U_HOVERED;
        }
    }

    public function clientSetHovered () :Boolean
    {
        return amOwner();
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

    override public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        bytes = super.toBytes(bytes);
        if ((_inState & U_HOVERED) > 0) {
            bytes.writeBoolean(_hovered);
        }
        return bytes;
    }

    override public function fromBytes (bytes :ByteArray) :void
    {
        super.fromBytes(bytes);
        if ((_inState & U_HOVERED) > 0) {
            _hovered = bytes.readBoolean();
        }
    }

    protected var _hovered :Boolean = false;
}
}
