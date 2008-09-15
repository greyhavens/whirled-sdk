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

import com.threerings.util.ClassUtil;

/**
 * The base class for any object that will exist in the platformer.
 */
public class Piece
{
    /** The piece coordinates. */
    public var x :int;
    public var y :int;

    /** The piece id. */
    public var id :int;

    /** The piece size. */
    public var height :int;
    public var width :int;

    /** The piece type. */
    public var type :String = "";

    /** The piece sprite name. */
    public var sprite :String = "";

    /** The orientation. */
    public var orient :int;

    public function Piece (defxml :XML = null, insxml :XML = null)
    {
        if (defxml != null) {
            type = defxml.@type;
            height = defxml.@height;
            width = defxml.@width;
            sprite = defxml.@sprite;
        }
        if (insxml != null) {
            if (defxml == null) {
                type = insxml.@type;
            }
            x = insxml.@x;
            y = insxml.@y;
            id = insxml.@id;
            orient = insxml.@orient;
            setXMLEditables(insxml);
        }
    }

    /**
     * Get the XML piece definition.
     */
    public function xmlDef () :XML
    {
        var xml :XML = <piecedef/>;
        xml.@type = type;
        xml.@cname = ClassUtil.getClassName(this);
        xml.@width = width;
        xml.@height = height;
        xml.@sprite = sprite;
        return xml;
    }

    /**
     * Get the XML instance definition.
     */
    public function xmlInstance () :XML
    {
        var xml :XML = getXMLEditables();
        xml.@type = type;
        xml.@x = x;
        xml.@y = y;
        xml.@id = id;
        xml.@orient = orient;
        return xml;
    }

    /**
     * Get the editable attributes.
     */
    public function getXMLEditables () :XML
    {
        var xml :XML = <piece/>;
        return xml;
    }

    public function setXMLEditables (xml :XML) :void
    {
    }

    public function toString () :String
    {
        return "piece: " + type + " (" + x + ", " + y + ")";
    }
}
}
