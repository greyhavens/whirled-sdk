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

package com.whirled.contrib.persist {

import flash.events.Event;
import flash.events.EventDispatcher;

import com.whirled.game.GameControl;

import com.threerings.util.Log;
import com.threerings.util.Map;
import com.threerings.util.Maps;

import com.whirled.game.PlayerSubControl;
import com.whirled.game.OccupantChangedEvent;

import com.whirled.contrib.EventHandlerManager;

public class PersistenceManager extends EventDispatcher
{
    public function PersistenceManager (gameCtrl :GameControl, cookieFactory :CookieFactory,
        debugLogging :Boolean = false)
    {
        _cookieFactory = cookieFactory;
        _debugLogging = debugLogging;
        _eventMgr = new EventHandlerManager();
        _eventMgr.registerUnload(_gameCtrl = gameCtrl);
        if (allPlayersPresent()) {
            init();
        } else {
            _eventMgr.registerListener(
                _gameCtrl.game, OccupantChangedEvent.OCCUPANT_ENTERED, occupantEntered);
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
        _eventMgr.callWhenTrue(callback, loaded, this, Event.COMPLETE);
    }

    /**
     * Server-side warning!  Any CookieProperties are essentially being read once at the game
     * start, and are currently not updated afterwards.  We'd need to add "refresh" functionality
     * to CookieManagers to deal with this - and we still wouldn't know when we have dirty data.
     */
    public function getProperty (name :String,
        playerId :int = 0 /*PlayerSubControl.CURRENT_USER*/) :PersistentProperty
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

    protected function init () :void
    {
        _trophyProperties = Maps.newMapOf(String);
        var cookiePropertyMaps :Map = Maps.newMapOf(int);
        for each (var prototype :PropertyPrototype in getPrototypes()) {
            switch (prototype.type) {
            case PropertyType.TROPHY:
                _trophyProperties.put(getPropertyKey(prototype.name, prototype.playerId),
                    new TrophyProperty(prototype.name, _gameCtrl, prototype.playerId));
                break;

            case PropertyType.TROPHY_PRIZE:
                _trophyProperties.put(getPropertyKey(prototype.name, prototype.playerId),
                    new TrophyPrizeProperty(prototype.name, _gameCtrl, prototype.playerId));

            case PropertyType.COOKIE:
                var cookieProperties :Map = cookiePropertyMaps.get(prototype.playerId);
                if (cookieProperties == null) {
                    cookiePropertyMaps.put(prototype.playerId,
                        cookieProperties = Maps.newMapOf(String));
                }
                cookieProperties.put(prototype.name, prototype);
                break;

            default:
                if (_debugLogging) {
                    log.debug("Unknown prototype type [" + prototype.type + "]");
                }
            }
        }

        _loaded = true;
        _cookieManagers = Maps.newMapOf(int);
        for each (var playerId :int in cookiePropertyMaps.keys()) {
            if (_debugLogging) {
                log.debug("adding CookieManager [" + playerId + "]");
            }

            cookieProperties = cookiePropertyMaps.get(playerId);
            var cookieManager :CookieManager = createCookieManager(cookieProperties, playerId);
            _loaded = _loaded && cookieManager.loaded;
            if (!cookieManager.loaded) {
                _eventMgr.registerOneShotCallback(cookieManager, Event.COMPLETE, loadingComplete);
            }
            _cookieManagers.put(playerId, cookieManager);
        }
        if (_loaded) {
            dispatchEvent(new Event(Event.COMPLETE));
        }
    }

    protected function getPrototypes () :Array
    {
        throw new Error("getPrototypes() in PersistenceManager is abstract");
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

    protected function allPlayersPresent () :Boolean
    {
        return _gameCtrl.game.seating.getPlayerIds().indexOf(0) < 0;
    }

    protected function occupantEntered (event :OccupantChangedEvent) :void
    {
        if (!allPlayersPresent()) {
            return;
        }

        _eventMgr.unregisterListener(
            _gameCtrl.game, OccupantChangedEvent.OCCUPANT_ENTERED, occupantEntered);
        init();
    }

    protected function createCookieManager (cookieProperties :Map, playerId :int) :CookieManager
    {
        return new CookieManager(
                _gameCtrl, cookieProperties, _cookieFactory, playerId, _debugLogging);
    }

    private static const log :Log = Log.getLog(PersistenceManager);

    protected var _gameCtrl :GameControl;
    protected var _cookieFactory :CookieFactory;
    protected var _debugLogging :Boolean;
    protected var _loaded :Boolean = false;
    protected var _trophyProperties :Map;
    protected var _cookieManagers :Map;
    protected var _eventMgr :EventHandlerManager;
}
}
