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

/**
 * A walkable solid dynamic that can be removed.
 */
public class Gate extends RectDynamic
{
    public var open :Boolean;

    public function Gate (insxml :XML = null)
    {
        super(insxml);
        if (insxml != null) {
            width = insxml.@width;
            height = insxml.@height;
            sprite = insxml.@sprite;
        }
    }

    override public function xmlInstance () :XML
    {
        var xml :XML = super.xmlInstance();
        xml.@type = "Gate";
        xml.@width = width;
        xml.@height = height;
        if (sprite != null) {
            xml.@sprite = sprite;
        }
        return xml;
    }

    override public function ownerType () :int
    {
        return OWN_ALL;
    }
}
}
