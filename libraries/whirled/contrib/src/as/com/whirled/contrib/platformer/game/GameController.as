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

import com.whirled.contrib.platformer.Controller;
import com.whirled.contrib.platformer.piece.Actor;
import com.whirled.contrib.platformer.piece.BoundedPiece;
import com.whirled.contrib.platformer.piece.Dynamic;
import com.whirled.contrib.platformer.piece.Piece;
import com.whirled.contrib.platformer.piece.Shot;
import com.whirled.contrib.platformer.board.Board;
import com.whirled.contrib.platformer.board.Collider;

import com.threerings.util.ClassUtil;
import com.threerings.util.HashMap;
import com.threerings.util.KeyboardCodes;

public class GameController
{
    public var forceX :Number = 0;
    public var forceY :Number = -4.8;
    public var colliderTicks :int;

    public function GameController (board :Board, controller :Controller)
    {
        _controller = controller;
        _board = board;
        _collider = genCollider();
        initDynamicClasses();
        _board.addEventListener(Board.ACTOR_ADDED, handleActorAdded);
        _board.addEventListener(Board.PIECE_LOADED, handlePieceLoaded);
        _board.addEventListener(Board.SHOT_ADDED, handleShotAdded);
        _board.addEventListener(Board.DYNAMIC_REMOVED, handleDynamicRemoved);
        _board.addEventListener(Board.DYNAMIC_ADDED, handleDynamicAdded);
    }

    public function initDynamicClasses () :void
    {
        addShotClass(Shot, ShotController, true);
    }

    public function run () :void
    {
    }

    public function tick (delta :int) :void
    {
        var rdelta :int = delta;
        while (rdelta > 0) {
            var tdelta :int = Math.min(MAX_TICK, rdelta);
            for each (var controller :Object in _controllers) {
                if (controller is TickController) {
                    (controller as TickController).tick(tdelta / 1000);
                }
            }
            var now :int = getTimer();
            _collider.tick(tdelta);
            colliderTicks += getTimer() - now;
            rdelta -= tdelta;
        }
        _controller.getSprite().tick(delta/1000);
        for each (controller in _controllers) {
            if (controller is TickController) {
                (controller as TickController).postTick();
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

    public function centerOn (ac :ActorController) :void
    {
        var a :Actor = ac.getActor();
        _controller.getSprite().centerOn(a.x, a.y);
    }

    public function ensureVisible (a :Actor) :void
    {
        _controller.getSprite().ensureVisible(a, getDy());
    }

    public function getDx () :Number
    {
        return _controller.getDx();
    }

    public function getDy () :Number
    {
        return _controller.getDy();
    }

    public function shooting () :Boolean
    {
        return _controller.isDown(KeyboardCodes.SHIFT);
    }

    public function jumping () :Boolean
    {
        return _controller.isDown(KeyboardCodes.SPACE);
    }

    public function addController (controller :Object) :void
    {
        _controllers.push(controller);
    }

    public function removeDynamicController (d :Dynamic) :DynamicController
    {
        var dc :DynamicController;
        for (var ii :int = 0; ii < _controllers.length; ii++) {
            if (_controllers[ii] is DynamicController && _controllers[ii].getDynamic() == d) {
                dc = _controllers[ii];
                _controllers.splice(ii, 1);
                _collider.removeDynamic(dc);
                break;
            }
        }
        return dc;
    }

    public function removeDynamic (d :Dynamic) :void
    {
        _board.removeDynamic(d);
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
        var className :String = ClassUtil.getClassName(actor);
        var aclass :Class = _actorMap.get(className);
        if (aclass == null) {
            aclass = _defaultActorClass;
        }
        var ac :ActorController = new aclass(actor, this);
        addController(ac);
        _collider.addDynamic(ac);
    }

    protected function handleShotAdded (shot :Shot, group :String) :void
    {
        var className :String = ClassUtil.getClassName(shot);
        var sclass :Class = _shotMap.get(className);
        if (sclass == null) {
            sclass = _defaultShotClass;
        }
        var sc :ShotController = new sclass(shot, this);
        addController(sc);
        _collider.addShot(sc);
    }

    protected function handleDynamicAdded (d :Dynamic, group :String) :void
    {
        var className :String = ClassUtil.getClassName(d);
        var dclass :Class = _dynamicMap.get(className);
        if (dclass == null) {
            dclass = _defaultDynamicClass;
        }
        var dc :DynamicController = new dclass(d, this);
        addController(dc);
        _collider.addDynamic(dc);
    }

    protected function handleDynamicRemoved (d :Dynamic, group :String) :void
    {
        removeDynamicController(d);
    }

    protected var _controller :Controller;

    protected var _controllers :Array = new Array();
    protected var _actorMap :HashMap = new HashMap();
    protected var _shotMap :HashMap = new HashMap();
    protected var _dynamicMap :HashMap = new HashMap();
    protected var _defaultActorClass :Class;
    protected var _defaultShotClass :Class;
    protected var _defaultDynamicClass :Class;

    protected var _board :Board;

    protected var _collider :Collider;

    protected static const MAX_TICK :int = 33;
}
}
