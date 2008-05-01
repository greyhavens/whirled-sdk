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

package com.whirled.contrib {

import flash.events.EventDispatcher;

import flash.utils.setTimeout;

import com.threerings.util.Log;

import com.whirled.ControlEvent;
import com.whirled.EntityControl;

/**
 * This class should be instantiated by any entity (a lamp, for example) that wishes to
 * synchronize with another entity (a lightswitch, for example) that is broadcasting some
 * part of its state using a @see EntityStatePublisher .
 */
public class EntityStateListener extends EventDispatcher
{
    public function EntityStateListener (
        control :EntityControl, key :String, updated :Function = null)
    {
        _key = key;
        _control = control;
        if (updated != null) {
            _updated = updated;
            _control.addEventListener(ControlEvent.ROOM_PROPERTY_CHANGED, handlePropertyChanged);
        }
    }

    public function get state () :Object
    {
        return _control.getRoomProperty(_key);
    }

    protected function handlePropertyChanged (event :ControlEvent) :void
    {
        if (event.name == _key) {
            _updated(_key, event.value);
        }
    }

    protected var _control :EntityControl;
    protected var _key :String;
    protected var _updated :Function;
}
}
