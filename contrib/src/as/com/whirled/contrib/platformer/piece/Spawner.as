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

public class Spawner extends RectDynamic
{
    public var spawnXML :XML;
    public var totalSpawns :int;
    public var maxConcurrent :int;
    public var spawnInterval :Number;
    public var spawnDelay :Number;
    public var deathInterval :Number;
    public var destructable :Boolean;
    public var health :Number;
    public var spawning :Boolean;
    public var spawns :Array;
    public var spawnCount :int;
    public var deathEffect :String;
    public var wasHit :Boolean;
    public var offX :Number;

    public function Spawner (insxml :XML = null)
    {
        super(insxml);
        if (insxml != null) {
            totalSpawns = insxml.@totalSpawns;
            spawnXML = insxml.dynamicdef[0];
            maxConcurrent = insxml.@maxConcurrent;
            destructable = insxml.@destructable == "true";
            health = insxml.@health;
            if (insxml.hasOwnProperty("@sprite")) {
                sprite = insxml.@sprite;
            }
            if (insxml.hasOwnProperty("@deathEffect")) {
                deathEffect = insxml.@deathEffect;
            }
            width = insxml.hasOwnProperty("@width") ? insxml.@width : 1;
            height = insxml.hasOwnProperty("@height") ? insxml.@height : 1;
            spawnInterval = insxml.@spawnInterval;
            spawnDelay = insxml.@spawnDelay;
            deathInterval = insxml.@deathInterval;
            offX = insxml.hasOwnProperty("@offX") ? insxml.@offX : 0;
        }
        inter = Dynamic.ENEMY;
    }

    override public function xmlInstance () :XML
    {
        var xml :XML = super.xmlInstance();
        xml.@totalSpawns = totalSpawns;
        xml.@maxConcurrent = maxConcurrent;
        if (spawnXML != null) {
            xml.appendChild(spawnXML);
        }
        if (deathEffect != null) {
            xml.@deathEffect = deathEffect;
        }
        xml.@destructable = destructable;
        xml.@health = health;
        xml.@width = width;
        xml.@height = height;
        xml.@spawnInterval = spawnInterval;
        xml.@spawnDelay = spawnDelay;
        xml.@deathInterval = deathInterval;
        xml.@offX = offX;
        if (sprite != null) {
            xml.@sprite = sprite;
        }
        return xml;
    }

    override public function shouldSpawn () :Boolean
    {
        return (!destructable || health > 0) && spawnXML != null;
    }
}
}
