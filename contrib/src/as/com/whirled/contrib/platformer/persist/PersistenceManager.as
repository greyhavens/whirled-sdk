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

import com.whirled.game.GameControl;

import com.threerings.util.HashMap;
import com.threerings.util.Log;

import com.whirled.game.PlayerSubControl;

import com.whirled.contrib.EventHandlerManager;

public class PersistenceManager extends EventDispatcher
{
    public function PersistenceManager (gameCtrl :GameControl, properties :Array, 
        debugLogging :Boolean = false)
    {
        _eventMgr = new EventHandlerManager();
        _eventMgr.registerUnload(gameCtrl);

        _trophyProperties = new HashMap();
        var cookiePropertyMaps :HashMap = new HashMap();
        for each (var prototype :PropertyPrototype in properties) {
            switch (prototype.type) {
            case PropertyType.TROPHY:
                _trophyProperties.put(getPropertyKey(prototype.name, prototype.playerId),
                    new TrophyProperty(prototype.name, gameCtrl, prototype.playerId));
                break;

            case PropertyType.COOKIE:
                var cookieProperties :HashMap = cookiePropertyMaps.get(prototype.playerId);
                if (cookieProperties == null) {
                    cookiePropertyMaps.put(prototype.playerId, cookieProperties = new HashMap());
                }
                cookieProperties.put(prototype.name, prototype.defaultValue);
                break;

            default:
                if (debugLogging) {
                    log.debug("Unknown prototype type [" + prototype.type + "]");
                }
            }
        }

        _loaded = true;
        _cookieManagers = new HashMap();
        for each (var playerId :int in cookiePropertyMaps.keys()) {
            cookieProperties = cookiePropertyMaps.get(playerId);
            var cookieManager :CookieManager = new CookieManager(
                gameCtrl, cookieProperties, playerId, debugLogging);
            _loaded = _loaded && cookieManager.loaded;
            if (!_loaded) {
                _eventMgr.registerOneShotCallback(cookieManager, Event.COMPLETE, loadingComplete);
            }
            _cookieManagers.put(playerId, cookieManager);
        }
    }

    public function get loaded () :Boolean
    {
        return _loaded;
    }

    /**
     * Call the given function when this manager is loaded.  If this manager is already loaded,
     * the given function will be called immediately.
     */
    public function whenLoaded (callback :Function) :void 
    {
        _eventMgr.conditionalCall(callback, loaded, this, Event.COMPLETE);
    }

    /**
     * Server-side warning!  Any CookieProperties are essentially being read once at the game
     * start, and are currently not updated afterwards.  We'd need to add "refresh" functionality
     * to CookieManagers to deal with this - and we still wouldn't know when we have dirty data.
     */
    public function getProperty (name :String, 
        playerId :int = PlayerSubControl.CURRENT_USER) :PersistentProperty
    {
        var trophyProperty :TrophyProperty = _trophyProperties.get(getPropertyKey(name, playerId));
        if (trophyProperty != null) {
            return trophyProperty;
        }

        var cookieManager :CookieManager = _cookieManagers.get(playerId) as CookieManager;
        if (cookieManager == null) {
            throw new Error("Unrecognized player! [" + playerId + "]");
        }
        return cookieManager.getProperty(name);
    }

    protected function loadingComplete () :void
    {
        _loaded = true;
        for each (var cookieManager :CookieManager in _cookieManagers.values()) {
            _loaded = _loaded && cookieManager.loaded;
            if (!_loaded) {
                return;
            }
        }

        dispatchEvent(new Event(Event.COMPLETE));
    }

    protected function getPropertyKey (name :String, playerId :int) :String
    {
        return name + "|" + playerId;
    }

    private static const log :Log = Log.getLog(PersistenceManager);

    protected var _loaded :Boolean = false;
    protected var _trophyProperties :HashMap;
    protected var _cookieManagers :HashMap;
    protected var _eventMgr :EventHandlerManager;
}
}
