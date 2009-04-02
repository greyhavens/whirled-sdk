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

package com.whirled.contrib.platformer.net {

import flash.events.Event;
import flash.utils.ByteArray;

import com.whirled.game.GameSubControl;

public class BaseGameMessage extends Event
    implements GameMessage
{
    public function BaseGameMessage ()
    {
        super(name);
    }

    public function get name () :String
    {
        throw new Error("name must be implemented");
        return null;
    }

    public function get senderId () :int
    {
        return _senderId;
    }

    public function set senderId (id :int) :void
    {
        _senderId = id;
    }

    public function fromServer () :Boolean
    {
        return _senderId == GameSubControl.SERVER_AGENT_ID;
    }

    public function fromBytes (bytes :ByteArray) :void
    {
        throw new Error("fromBytes must be implemented");
    }

    public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        throw new Error("toBytes must be implemented");
        return null;
    }

    protected var _senderId :int;
}
}
