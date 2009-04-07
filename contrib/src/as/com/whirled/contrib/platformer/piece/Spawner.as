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

import com.threerings.util.Enum;

import com.whirled.contrib.platformer.PlatformerContext;
import com.whirled.contrib.platformer.board.Board;
import com.whirled.contrib.platformer.game.Collision;
import com.whirled.contrib.platformer.sound.SoundEffect;
import com.whirled.contrib.platformer.util.Effect;

public class Spawner extends RectDynamic
{
    public static const U_HEALTH :int = 1 << (DYN_COUNT + 1);
    public static const U_SPAWN :int = 1 << (DYN_COUNT + 2);

    public var spawnXML :XML;
    public var totalSpawns :int;
    public var maxConcurrent :int;
    public var spawnInterval :Number;
    public var spawnDelay :Number;
    public var deathInterval :Number;
    public var destructable :Boolean;
    public var deathEffect :Effect;
    public var offX :Number;
    public var spawns :Array;
    public var disabled :Boolean;
    public var spawnSoundEffect :SoundEffect;
    public var deathSoundEffect :SoundEffect;
    public var hitCollision :Collision;
    public var missCollision :Collision;
    public var wasHit :Boolean;

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
                deathEffect = PlatformerContext.getEffect(insxml.@deathEffect);
            }
            if (insxml.hasOwnProperty("@spawnSoundEffect")) {
                spawnSoundEffect = PlatformerContext.getSoundEffect(insxml.@spawnSoundEffect);
            }
            if (insxml.hasOwnProperty("@deathSoundEffect")) {
                deathSoundEffect = PlatformerContext.getSoundEffect(insxml.@deathSoundEffect);
            }
            width = insxml.hasOwnProperty("@width") ? insxml.@width : 1;
            height = insxml.hasOwnProperty("@height") ? insxml.@height : 1;
            spawnInterval = insxml.@spawnInterval;
            spawnDelay = insxml.@spawnDelay;
            deathInterval = insxml.@deathInterval;
            offX = insxml.hasOwnProperty("@offX") ? insxml.@offX : 0;
            disabled = insxml.@disabled == "true";
            hitCollision = PlatformerContext.getCollision(insxml.@hitCollision);
            missCollision = PlatformerContext.getCollision(insxml.@missCollision);
        }
        inter = Dynamic.ENEMY;
    }

    public function get health () :Number
    {
        return _health;
    }

    public function set health (health :Number) :void
    {
        _health = health;
        updateState |= U_HEALTH;
    }

    public function get killer () :int
    {
        return _killer;
    }

    public function set killer (killer :int) :void
    {
        _killer = killer;
        updateState |= U_HEALTH;
    }

    public function get spawning () :int
    {
        return _spawning;
    }

    public function set spawning (spawning :int) :void
    {
        _spawning = spawning;
        updateState |= U_SPAWN;
    }

    public function get spawnCount () :int
    {
        return _spawnCount;
    }

    public function set spawnCount (spawnCount :int) :void
    {
        _spawnCount = spawnCount;
        //updateState |= U_SPAWN;
    }

    override public function get enemyCount () :int
    {
        if (destructable) {
            return super.enemyCount;
        }
        return totalSpawns - spawnCount + (spawns == null ? 0 : spawns.length);
    }

    public function genActor (id :int) :Actor
    {
        var cxml :XML = spawnXML.copy();
        cxml.@x = x + width/2 + offX;
        cxml.@y = y;
        var a :Actor = Board.loadDynamic(cxml) as Actor;
        a.id = id;
        a.owner = owner;
        return a;
    }

    override public function alwaysSpawn () :Boolean
    {
        if (spawning != 0) {
            return true;
        }
        if (spawns == null || spawns.length == 0 || spawning == 0) {
            return false;
        }
        for each (var id :int in spawns) {
            if (PlatformerContext.board.getActors()[id] == null) {
                return false;
            }
        }
        return true;
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
        if (spawnSoundEffect != null) {
            xml.@spawnSoundEffect = spawnSoundEffect;
        }
        if (deathSoundEffect != null) {
            xml.@deathSoundEffect = deathSoundEffect;
        }
        xml.@destructable = destructable;
        xml.@health = health;
        xml.@width = width;
        xml.@height = height;
        xml.@spawnInterval = spawnInterval;
        xml.@spawnDelay = spawnDelay;
        xml.@deathInterval = deathInterval;
        xml.@offX = offX;
        xml.@disabled = disabled;
        if (sprite != null) {
            xml.@sprite = sprite;
        }
        xml.@hitCollision = hitCollision;
        xml.@missCollision = missCollision;
        return xml;
    }

    override public function shouldSpawn () :Boolean
    {
        return (!destructable || health > 0) && spawnXML != null;
    }

    override public function isAlive () :Boolean
    {
        return destructable ? super.isAlive() :
            (spawnCount < totalSpawns || spawns != null || spawns.length > 0);
    }

    override public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        bytes = super.toBytes(bytes);
        if ((_inState & U_HEALTH) > 0) {
            bytes.writeFloat(_health);
            bytes.writeInt(_killer);
        }
        if ((_inState & U_SPAWN) > 0) {
            bytes.writeInt(_spawning);
            //bytes.writeByte(_spawnCount);
        }
        return bytes;
    }

    override public function fromBytes (bytes :ByteArray) :void
    {
        super.fromBytes(bytes);
        if ((_inState & U_HEALTH) > 0) {
            _health = bytes.readFloat();
            _killer = bytes.readInt();
        }
        if ((_inState & U_SPAWN) > 0) {
            _spawning = bytes.readInt();
            //_spawnCount = bytes.readByte();
        }
    }

    protected var _health :Number;
    protected var _spawning :int;
    protected var _spawnCount :int;
    protected var _killer :int;
}
}
