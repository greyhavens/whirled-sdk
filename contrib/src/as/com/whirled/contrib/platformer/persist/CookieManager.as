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

package com.whirled.contrib.platformer.persist {

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.utils.ByteArray;
import flash.utils.Timer;
import flash.utils.getTimer; // function import

import com.threerings.util.HashMap;
import com.threerings.util.Log;

import com.whirled.game.GameControl;

public class CookieManager extends EventDispatcher
{
    public function CookieManager (gameCtrl :GameControl, properties :HashMap, 
        debugLogging :Boolean = false)
    {
        _gameCtrl = gameCtrl;
        _propertyDefaults = properties;
        _debug = debugLogging;
        _properties = new HashMap();

        _gameCtrl.player.getCookie(gotCookie);
    }

    public function get loaded () :Boolean
    {
        return _loaded;
    }

    public function getProperty (name :String) :CookieProperty
    {
        var property :CookieProperty = _properties.get(name);
        if (property != null) {
            return property;
        }

        if (!_propertyDefaults.containsKey(name)) {
            throw new Error("Property is unknown to this CookieManager [" + name + "]");
        }

        var defaultValue :Object = _propertyDefaults.get(name);
        if (defaultValue is int) {
            return new IntCookieProperty(this, name, defaultValue as int);

        } else {
            throw new Error("CookieManager does not know how to handle this type of value [" + 
                defaultValue + "]");
        }
    }

    public function cookiePropertyUpdated (property :CookieProperty) :void
    {
        if (_timer != null) {
            // we're already waiting to do a write
            return;
        }

        if (!_properties.containsKey(property.name)) {
            // if a default value property was magicked up at runtime, it won't have been added
            // to the saved properties yet.
            _properties.put(property.name, property);
        }

        var timeRemaining :int = (_lastWrite + WRITE_DELAY) - getTimer();
        if (timeRemaining > 0) {
            _timer = new Timer(timeRemaining, 1);
            _timer.addEventListener(TimerEvent.TIMER, writeCookie);
            _timer.start();

        } else {
            writeCookie();
        }
    }

    protected function gotCookie (cookie :Object, occupantId :int) :void
    {
        if (occupantId != _gameCtrl.game.getMyId()) {
            throw new Error("Unexpectedly received the cookie for another player [" + 
                _gameCtrl.game.getMyId() + ", " + occupantId + "]");
        }

        if (cookie == null) {
            dispatchLoaded();
            return;
        }

        if (!(cookie is ByteArray)) {
            throw new Error("Cookie is not a ByteArray [" + cookie + "]");
        }

        var bytes :ByteArray = cookie as ByteArray;
        bytes.uncompress();
        var version :int = bytes.readInt();
        if (version > VERSION) {
            throw new Error("Received a cookie that is newer than we are capable of reading [" +
                version + ", " + VERSION + "]");
        }
        // there are currently no legacy versions to migrate
        
        while (bytes.bytesAvailable > 0) {
            var typeId :int = bytes.readInt();
            var typeClass :Class = CookiePropertyType.getClass(typeId);

            var property :CookieProperty = new typeClass(this) as CookieProperty;
            property.deserialize(bytes);
            _properties.put(property.name, property);

            if (_debug) {
                log.debug("Read property out of cookie [" + property + "]");
            }
        }

        dispatchLoaded();
    }

    protected function dispatchLoaded () :void
    {
        _loaded = true;
        dispatchEvent(new Event(Event.COMPLETE));
    }

    protected function writeCookie (...ignored) :void
    {
        if (_timer != null) {
            _timer.removeEventListener(TimerEvent.TIMER, writeCookie);
            _timer = null;
        }

        var bytes :ByteArray = new ByteArray();
        bytes.writeInt(VERSION);

        for each (var property :CookieProperty in _properties.values()) {
            bytes.writeInt(property.typeId);
            property.serialize(bytes);
        }

        bytes.compress();
        _gameCtrl.player.setCookie(bytes);
        _lastWrite = getTimer();
    }

    protected var _gameCtrl :GameControl;
    protected var _properties :HashMap;
    protected var _propertyDefaults :HashMap;
    protected var _loaded :Boolean = false;
    protected var _lastWrite :int = 0;
    protected var _timer :Timer = null;
    protected var _debug :Boolean;

    /** Version bumps are not required when adding new data types.  Only if another form of 
     * storing data in the cookie is fashioned should a version bump be necessary. */
    protected static const VERSION :int = 1;
    
    /** Write out the cookie at most every 2 seconds, in order to prevent this manager from 
     * sucking up network resources */
    protected static const WRITE_DELAY :int = 2000; // in ms.

    protected static const log :Log = Log.getLog(CookieManager);
}
}