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
import com.whirled.contrib.platformer.game.Collision;

/**
 * A gate that can be destroyed by shooting.
 */
public class DestructableGate extends Gate
{
    public static const U_HEALTH :int = 1 << (DYN_COUNT + 1);
    public static const GATE_COUNT :int = DYN_COUNT + 1;

    public var startHealth :Number;
    public var wasHit :Boolean;
    public var playerImpervious :Boolean;
    public var hitCollision :Collision;
    public var missCollision :Collision;

    public function DestructableGate (insxml :XML = null)
    {
        super(insxml);
        if (insxml != null) {
            health = insxml.@health;
            startHealth = insxml.@health;
            playerImpervious = insxml.@playerImpervious == "true";
            hitCollision = PlatformerContext.getCollision(insxml.@hitCollision);
            missCollision = PlatformerContext.getCollision(insxml.@missCollision);
        }
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

    override public function xmlInstance() :XML
    {
        var xml :XML = super.xmlInstance();
        xml.@health = health;
        xml.@playerImpervious = playerImpervious;
        xml.@hitCollision = hitCollision;
        xml.@missCollision = missCollision;
        return xml;
    }

    override public function ownerType () :int
    {
        return OWN_SERVER;
    }

    override public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        bytes = super.toBytes(bytes);
        if ((_inState & U_HEALTH) > 0) {
            bytes.writeFloat(_health);
        }
        return bytes;
    }

    override public function fromBytes (bytes :ByteArray) :void
    {
        super.fromBytes(bytes);
        if ((_inState & U_HEALTH) > 0) {
            _health = bytes.readFloat();
        }
    }

    protected var _health :Number;
}
}
