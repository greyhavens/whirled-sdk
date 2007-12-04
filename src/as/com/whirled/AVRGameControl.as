//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled {

import flash.display.DisplayObject;

import flash.geom.Point;
import flash.geom.Rectangle;

import flash.utils.Dictionary;

import com.threerings.util.Log;

/**
 * Dispatched either when somebody in our room entered our current game,
 * or somebody playing the game entered our current room.
 * 
 * @eventType com.whirled.AVRGameControlEvent.PLAYER_ENTERED
 */
[Event(name="playerEntered", type="com.whirled.AVRGameControlEvent")]

/**
 * Dispatched either when somebody in our room left our current game,
 * or somebody playing the game left our current room.
 * 
 * @eventType com.whirled.AVRGameControlEvent.PLAYER_LEFT
 */
[Event(name="playerLeft", type="com.whirled.AVRGameControlEvent")]

/**
 * Dispatched when another player in our current room took up a new location.
 * 
 * @eventType com.whirled.AVRGameControlEvent.PLAYER_MOVED
 */
[Event(name="playerMoved", type="com.whirled.AVRGameControlEvent")]

/**
 * Dispatched when we've entered our current room.
 * 
 * @eventType com.whirled.AVRGameControlEvent.ENTERED_ROOM
 */
[Event(name="enteredRoom", type="com.whirled.AVRGameControlEvent")]

/**
 * Dispatched when we've left our current room.
 * 
 * @eventType com.whirled.AVRGameControlEvent.LEFT_ROOM
 */
[Event(name="leftRoom", type="com.whirled.AVRGameControlEvent")]

/**
 * This file should be included by AVR games so that they can communicate
 * with the whirled.
 *
 * AVRGame means: Alternate Virtual Reality Game, and refers to games
 * played within the whirled environment.
 */
public class AVRGameControl extends WhirledControl
{
    /**
     * Create a world game interface. The display object is your world game.
     */
    public function AVRGameControl (disp :DisplayObject)
    {
        super(disp);

        // set up the default hitPointTester
        _hitPointTester = disp.root.hitTestPoint;
    }

    /**
     * Returns the bounds of the "stage" on which the AVRG will be drawn. This is the entire
     * area the AVRG can cover and includes potential empty space to the right of the room
     * view. See <code>getRoomBounds</code>.
     */
    public function getStageBounds () :Rectangle
    {
        return Rectangle(callHostCode("getStageBounds_v1"));
    }

    /**
     * Get the room's bounds in pixel coordinates. This is essentially the width and height
     * of the room's decor. It is an absolute coordinate system, i.e. (x, y) for one client
     * here is the same (x, y) as for another.
     *
     * @return a Rectangle anchored in (0, 0)
     */
    public function getRoomBounds () :Rectangle
    {
        return callHostCode("getRoomBounds_v1") as Rectangle;
    }

    public function stageToRoom (p :Point) :Point
    {
        return callHostCode("stageToRoom_v1", p) as Point;
    }

    public function roomToStage (p :Point) :Point
    {
        return callHostCode("roomToStage_v1", p) as Point;
    }

    /**
     * Get the QuestControl, which contains methods for enumerating, offering, advancing,
     * cancelling and completing quests.
     */
    public function get quests () :QuestControl
    {
        return _quests;
    }

    /**
     * Get the StateControl, which contains methods for getting and setting properties
     * on AVRG's, both game-global and player-centric.
     */
    public function get state () :StateControl
    {
        return _state;
    }

    /**
     * Configures the AVRG with a function to call to determine which pixels are alive
     * for mouse purposes and which are not. By default, all non-transparent pixels will
     * capture the mouse. The prototype for this method is identical to what the Flash
     * API establishes in DisplayObject:
     *    testHitPoint(x :Number, y :Number, shapeFlag :Boolean) :Boolean
     *
     * {@see DisplayObject#testHitPoint}
     */
    public function setHitPointTester (tester :Function) :void
    {
        _hitPointTester = tester;
    }

    /**
     * Returns the AVRG's currently configured hit point tester.
     *
     * {@see #setHitPointTester}
     */
    public function get hitPointTester () :Function
    {
        return _hitPointTester;
    }

    public function setMobSpriteExporter (exporter :Function) :void
    {
        _mobSpriteExporter = exporter;
    }

    public function get mobSpriteExporter () :Function
    {
        return _mobSpriteExporter;
    }

    public function deactivateGame () :Boolean
    {
        return callHostCode("deactivateGame_v1");
    }

    public function getRoomId () :int
    {
        return callHostCode("getRoomId_v1") as int;
    }

    public function getPlayerId () :int
    {
        return callHostCode("getPlayerId_v1") as int;
    }

    public function isPlayerHere (id :int) :Boolean
    {
        return callHostCode("isPlayerHere_v1", id);
    }

    public function getPlayerIds () :Array
    {
        return callHostCode("getPlayerIds_v1") as Array;
    }

    public function spawnMob (id :String) :Boolean
    {
        return callHostCode("spawnMob_v1", id);
    }

    override protected function isAbstract () :Boolean
    {
        return false;
    }

    override protected function populateProperties (o :Object) :void
    {
        super.populateProperties(o);

        o["playerLeft_v1"] = playerLeft_v1;
        o["playerEntered_v1"] = playerEntered_v1;
        o["leftRoom_v1"] = leftRoom_v1;
        o["enteredRoom_v1"] = enteredRoom_v1;
        o["panelResized_v1"] = panelResized_v1;
        o["hitTestPoint_v1"] = hitTestPoint_v1;

        o["requestMobSprite_v1"] = requestMobSprite_v1;
        o["mobRemoved_v1"] = mobRemoved_v1;
        o["mobAppearanceChanged_v1"] = mobAppearanceChanged_v1;

        _state = new StateControl(this);
        _state.populateSubProperties(o);

        _quests = new QuestControl(this);
        _quests.populateSubProperties(o);
    }

    protected function requestMobSprite_v1 (id :String) :DisplayObject
    {
        var info :MobEntry = _mobs[id];
        if (info) {
            Log.getLog(this).warning(
                "Sprite requested for previously known mob [id=" + id + "]");
            return info.sprite;
        }
        if (_mobSpriteExporter == null) {
            Log.getLog(this).warning(
                "Sprite requested but control has no exporter [id=" + id + "]");
            return null;
        }
        var ctrl :MobControl = new MobControl(this, id);
        var sprite :DisplayObject = _mobSpriteExporter(id, ctrl) as DisplayObject;
        Log.getLog(this).debug("Requested sprite [id=" + id + ", sprite=" + sprite + "]");
        if (sprite) {
            _mobs[id] = new MobEntry(ctrl, sprite);
        }
        return sprite;
    }

    protected function mobRemoved_v1 (id :String) :void
    {
        Log.getLog(this).debug("Nuking control [id=" + id + "]");
        delete _mobs[id];
    }

    protected function mobAppearanceChanged_v1 (
        id :String, locArray :Array, orient :Number, moving :Boolean, idle :Boolean) :void
    {
        var entry :MobEntry = _mobs[id];
        if (entry) {
            entry.control.appearanceChanged(locArray, orient, moving, idle);
        }
    }

    protected function hitTestPoint_v1 (x :Number, y :Number, shapeFlag :Boolean) :Boolean
    {
        return _hitPointTester != null && _hitPointTester(x, y, shapeFlag);
    }

    protected function playerLeft_v1 (id :int) :void
    {
        dispatchEvent(new AVRGameControlEvent(AVRGameControlEvent.PLAYER_LEFT, null, id));
    }

    protected function playerEntered_v1 (id :int) :void
    {
        dispatchEvent(new AVRGameControlEvent(AVRGameControlEvent.PLAYER_ENTERED, null, id));
    }

    protected function playerMoved_v1 (id :int) :void
    {
        dispatchEvent(new AVRGameControlEvent(AVRGameControlEvent.PLAYER_MOVED, null, id));
    }

    protected function leftRoom_v1 () :void
    {
        dispatchEvent(new AVRGameControlEvent(AVRGameControlEvent.LEFT_ROOM));
    }

    protected function enteredRoom_v1 (newScene :int) :void
    {
        dispatchEvent(new AVRGameControlEvent(AVRGameControlEvent.ENTERED_ROOM, null, newScene));
    }

    protected function panelResized_v1 () :void
    {
        dispatchEvent(new AVRGameControlEvent(AVRGameControlEvent.SIZE_CHANGED));
    }

    protected var _quests :QuestControl;
    protected var _state :StateControl;

    protected var _mobSpriteExporter :Function;
    protected var _hitPointTester :Function;

    protected var _mobs :Dictionary = new Dictionary();
}
}

import flash.display.DisplayObject;

import com.whirled.MobControl;

class MobEntry
{
    public var control :MobControl;
    public var sprite :DisplayObject;

    public function MobEntry (control :MobControl, sprite :DisplayObject)
    {
        this.control = control;
        this.sprite = sprite;
    }
}
