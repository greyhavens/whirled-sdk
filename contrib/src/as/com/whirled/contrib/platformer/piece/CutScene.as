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
 * A hover that takes control of the player while it's running.
 */
public class CutScene extends Hover
{
    public var played :Boolean;
    public var stage :int;
    public var stageChanges :Array;
    public var spawnX :Number = 0;
    public var spawnY :Number = 0;

    public function CutScene (insxml :XML = null)
    {
        super(insxml);
        if (insxml != null) {
            var str :String = insxml.@stageChanges;
            stageChanges = str.split(/,/);
            stageChanges.forEach(function (item :*, index:int, array:Array) :void {
                array[index] = Number(item);
            });
            spawnX = insxml.@spawnX;
            spawnY = insxml.@spawnY;
        }
    }

    override public function xmlInstance () :XML
    {
        var xml :XML = super.xmlInstance();
        xml.@stageChanges = stageChanges.join(",");
        xml.@spawnX = spawnX;
        xml.@spawnY = spawnY;
        return xml;
    }
}
}
