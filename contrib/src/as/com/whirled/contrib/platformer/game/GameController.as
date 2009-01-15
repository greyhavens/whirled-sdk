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

package com.whirled.contrib.platformer.game {

import flash.utils.getTimer;

//import com.whirled.contrib.platformer.Controller;
import com.whirled.contrib.platformer.PlatformerContext;
import com.whirled.contrib.platformer.board.Board;
import com.whirled.contrib.platformer.board.Collider;
import com.whirled.contrib.platformer.net.DynamicMessage;
import com.whirled.contrib.platformer.net.TickMessage;
import com.whirled.contrib.platformer.piece.Actor;
import com.whirled.contrib.platformer.piece.BoundedPiece;
import com.whirled.contrib.platformer.piece.DestructableGate;
import com.whirled.contrib.platformer.piece.Dynamic;
//import com.whirled.contrib.platformer.piece.RectDynamic;
import com.whirled.contrib.platformer.piece.Gate;
import com.whirled.contrib.platformer.piece.Hover;
import com.whirled.contrib.platformer.piece.LaserShot;
import com.whirled.contrib.platformer.piece.Piece;
import com.whirled.contrib.platformer.piece.Shot;
import com.whirled.contrib.platformer.piece.Spawner;

import com.threerings.util.ClassUtil;
import com.threerings.util.HashMap;
import com.threerings.util.KeyboardCodes;

public class GameController
{
    public var forceX :Number = 0;
    public var forceY :Number = -4.8;
    public var colliderTicks :int;
    public var ticked :int;

    public function GameController ()
    {
        _board = PlatformerContext.board;
        _collider = genCollider();
        initDynamicClasses();
        _board.addEventListener(Board.ACTOR_ADDED, handleActorAdded);
        _board.addEventListener(Board.PIECE_LOADED, handlePieceLoaded);
        _board.addEventListener(Board.SHOT_ADDED, handleShotAdded);
        _board.addEventListener(Board.DYNAMIC_REMOVED, handleDynamicRemoved);
        _board.addEventListener(Board.DYNAMIC_ADDED, handleDynamicAdded);

        // We need to reference our various event classes so they're compiled
        var c :Class = RemoveGatesEventAction;
        c = DeathEventTrigger;
        c = SetGateEventAction;
        c = ImmediateEventTrigger;
        c = MultiEventAction;
        c = SpawnerDeathEventTrigger;
        c = MultiEventTrigger;
        c = OpenGateEventAction;
        c = EnableSpawnerEventAction;
    }

    public function initDynamicClasses () :void
    {
        addShotClass(Shot, ShotController, true);
        addShotClass(LaserShot, LaserShotController);
        addDynamicClass(Dynamic, DynamicController, true);
        addDynamicClass(Hover, HoverController);
        addDynamicClass(Spawner, SpawnerController);
        addDynamicClass(Gate, GateController);
        addDynamicClass(DestructableGate, DestructableGateController);
    }

    public function run () :void
    {
        for each (var d :Dynamic in _board.getDynamicIns()) {
            var dc :DynamicController = getController(d);
            if (dc != null) {
                if (dc is InitController) {
                    (dc as InitController).init();
                }
                if (dc is ShutdownController) {
                    (dc as ShutdownController).shutdown();
                }
            }
        }
        var eventsXML :XML = _board.getEventXML();
        if (eventsXML != null) {
            for each (var node :XML in eventsXML.child("event")) {
                if (addGameEvent(GameEvent.create(this, node))) {
                    //trace("adding event: " + node.toXMLString());
                }
            }
        }
    }

    public function shutdown () :void
    {
        for each (var o :Object in _controllers) {
            if (o is ShutdownController) {
                o.shutdown();
            }
        }
        _board.removeEventListener(Board.ACTOR_ADDED, handleActorAdded);
        _board.removeEventListener(Board.PIECE_LOADED, handlePieceLoaded);
        _board.removeEventListener(Board.SHOT_ADDED, handleShotAdded);
        _board.removeEventListener(Board.DYNAMIC_REMOVED, handleDynamicRemoved);
        _board.removeEventListener(Board.DYNAMIC_ADDED, handleDynamicAdded);
    }

    public function setPause (pause :Boolean) :void
    {
        _pause = pause;
    }

    public function isPaused () :Boolean
    {
        return _pause;
    }

    public function tick (delta :int) :void
    {
        _rdelta += delta;
        var usedDelta :int;
        while (_rdelta > 0) {
            var paused :Boolean = isPaused();
            var tdelta :int = Math.min(MAX_TICK, _rdelta);
            var sdelta :Number = tdelta / 1000;
            for each (var controller :Object in _controllers) {
                if (controller is TickController &&
                        (!paused || controller is PauseController)) {
                    tickController(controller as TickController, sdelta);
                }
            }
            if (!paused) {
                var now :int = getTimer();
                _collider.tick(tdelta);
                colliderTicks += getTimer() - now;
            }
            ticked++;
            _rdelta -= tdelta;
            usedDelta += tdelta;
            sendUpdates();
            if (_rdelta < MAX_TICK) {
                break;
            }
        }
        updateDisplay(usedDelta/1000);
        for each (controller in _controllers) {
            if (controller is TickController && (!paused || controller is PauseController)) {
                (controller as TickController).postTick();
            }
        }
        if (!paused) {
            var ii :int = 0;
            while (ii < _events.length) {
                if (_events[ii].runEvent()) {
                    _events.splice(ii, 1);
                } else {
                    ii++;
                }
            }
        }
    }

    public function getBoard () :Board
    {
        return _board;
    }

    public function getCollider () :Collider
    {
        return _collider;
    }

    public function addController (controller :Object) :Boolean
    {
        _controllers.push(controller);
        return true;
    }

    public function removeDynamicController (d :Dynamic) :DynamicController
    {
        if (!d.needServerController() && PlatformerContext.gctrl.game.amServerAgent()) {
            return null;
        }
        var dc :DynamicController;
        for (var ii :int = 0; ii < _controllers.length; ii++) {
            if (_controllers[ii] is DynamicController && _controllers[ii].getDynamic() == d) {
                dc = _controllers[ii];
                _controllers.splice(ii, 1);
                _collider.removeDynamic(dc);
                dc.shutdown();
                break;
            }
        }
        return dc;
    }

    public function removeDynamic (d :Dynamic) :void
    {
        _board.removeDynamic(d);
    }

    public function setBound (idx :int, bound :int) :void
    {
        if (bound != _board.getBound(idx)) {
            _board.setBound(idx, bound);
            _collider.setBound(idx, bound);
        }
    }

    public function addGameEvent (ge :GameEvent) :Boolean
    {
        if (ge != null) {
            _events.push(ge);
            return true;
        }
        return false;
    }

    protected function genCollider () :Collider
    {
        throw new Error("Must initialize collider in subclass");
    }

    protected function addActorClass (a :Class, ac :Class, isDefault :Boolean = false) :void
    {
        _actorMap.put(ClassUtil.getClassName(a), ac);
        if (isDefault) {
            _defaultActorClass = ac;
        }
    }

    protected function addShotClass (s :Class, sc :Class, isDefault :Boolean = false) :void
    {
        _shotMap.put(ClassUtil.getClassName(s), sc);
        if (isDefault) {
            _defaultShotClass = sc;
        }
    }

    protected function addDynamicClass (d :Class, dc :Class, isDefault :Boolean = false) :void
    {
        _dynamicMap.put(ClassUtil.getClassName(d), dc);
        if (isDefault) {
            _defaultDynamicClass = dc;
        }
    }

    protected function handlePieceLoaded (p :Piece, tree :String) :void
    {
        if (p is BoundedPiece) {
            _collider.addBoundedPiece(p as BoundedPiece);
        }
    }

    protected function handleActorAdded (actor :Actor, group :String) :void
    {
        var dc :DynamicController = getController(actor);
        if (dc != null && addController(dc)) {
            _collider.addDynamic(dc);
        }
    }

    protected function handleShotAdded (shot :Shot, group :String) :void
    {
        var dc :DynamicController = getController(shot);
        if (dc != null && addController(dc)) {
            _collider.addShot(dc as ShotController);
        }
    }

    protected function handleDynamicAdded (d :Dynamic, group :String) :void
    {
        var dc :DynamicController = getController(d);
        if (dc != null && addController(dc)) {
            _collider.addDynamic(dc);
        }
    }

    protected function getController (d :Dynamic) :DynamicController
    {
        if (!d.needServerController() && PlatformerContext.gctrl.game.amServerAgent()) {
            return null;
        }
        var className :String = ClassUtil.getClassName(d);
        var dclass :Class;
        if (d is Actor) {
            dclass = _actorMap.get(className);
            if (dclass == null) {
                dclass = _defaultActorClass;
            }
        } else if (d is Shot) {
            dclass = _shotMap.get(className);
            if (dclass == null) {
                dclass = _defaultShotClass;
            }
        } else {
            dclass = _dynamicMap.get(className);
            if (dclass == null) {
                dclass = _defaultDynamicClass;
            }
        }
        return new dclass(d, this);
    }

    protected function handleDynamicRemoved (d :Dynamic, group :String) :void
    {
        removeDynamicController(d);
    }

    protected function updateDisplay (delta :Number) :void
    {
    }

    protected function tickController (tc :TickController, delta :Number) :void
    {
        tc.tick(delta);
    }

    protected function sendUpdates () :void
    {
        if (PlatformerContext.local) {
            return;
        }
        for each (var d :Dynamic in PlatformerContext.board.getActors()) {
            if (!d.amOwner() || d.ownerType() == Dynamic.OWN_ALL) {
                continue;
            }
            d.updateState |= Dynamic.U_POS;
            PlatformerContext.net.sendMessage(DynamicMessage.wrap(d));
        }
        for each (d in PlatformerContext.board.getDynamics()) {
            if (!d.amOwner() || d.ownerType() == Dynamic.OWN_ALL) {
                continue;
            }
            if (d.updateState != 0) {
                PlatformerContext.net.sendMessage(DynamicMessage.wrap(d));
            }
        }
        PlatformerContext.net.sendMessage(new TickMessage());
    }

    protected var _controllers :Array = new Array();
    protected var _actorMap :HashMap = new HashMap();
    protected var _shotMap :HashMap = new HashMap();
    protected var _dynamicMap :HashMap = new HashMap();
    protected var _events :Array = new Array();
    protected var _defaultActorClass :Class;
    protected var _defaultShotClass :Class;
    protected var _defaultDynamicClass :Class;

    protected var _board :Board;

    protected var _pause :Boolean;

    protected var _collider :Collider;
    protected var _rdelta :int;

    protected static const MAX_TICK :int = 33;
    //protected static const MAX_TICK :int = 40;
}
}
