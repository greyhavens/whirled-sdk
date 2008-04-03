//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled {

import com.threerings.util.Log;

import flash.display.DisplayObject;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

/**
 * Dispatched when this client-side instance of the AVRG
 * has gained "control" over the other client-side instances.
 *
 * @eventType com.whirled.AVRGameControlEvent.GOT_CONTROL
 */
[Event(name="gotControl", type="com.whirled.AVRGameControlEvent")]

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
 * Dispatched when the control has been resized.
 *
 * @eventType com.whirled.AVRGameControlEvent.SIZE_CHANGED
 */
[Event(name="sizeChanged", type="com.whirled.AVRGameControlEvent")]

/**
 * Dispatched when something has changed about a player's
 * avatar.
 *
 * @eventType com.whirled.AVRGameControlEvent.AVATAR_CHANGED
 */
[Event(name="avatarChanged", type="com.whirled.AVRGameControlEvent")]

/**
 * This file should be included by AVR games so that they can communicate
 * with the whirled.
 *
 * AVRGame means: Alternate Virtual Reality Game, and refers to games
 * played within the whirled environment with your avatar.
 *
 * <p><b>Note</b>: The AVRG framework is "alpha" and may be changed in incompatible ways.
 * If you are making an AVRG game, please let us know what you're doing in the AVRG
 * discussion forum: <a href="http://first.whirled.com/#whirleds-d_135_r">http://first.whirled.com/#whirleds-d_135_r</a></p>
 */
public class AVRGameControl extends AbstractControl
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
     * Returns the bounds of the "stage" on which the AVRG will be drawn.
     * This value changes when the browser is resized, and when the player moves to another room.

	 * @param full If true (the default), return the entire paintable area. If false,
	 * return the area occupied by the room's decor, which can be smaller than the entire
	 * paintable area if narrow rooms, or when the room view is zoomed out.
	 *
	 * @return a Rectangle containing the stage bounds
     */
    public function getStageSize (full :Boolean = true) :Rectangle
    {
        return Rectangle(callHostCode("getStageSize_v1", full));
    }

    /**
     * Get the room's bounds in pixel coordinates. This is essentially the width and height
     * of the room's decor. It is an absolute coordinate system, i.e. (x, y) for one client
     * here is the same (x, y) as for another.
     *
     * @return a Rectangle anchored at (0, 0)
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

    public function locationToRoom (x :Number, y :Number, z :Number) :Point
    {
        return callHostCode("locationToRoom_v1", x, y, z) as Point;
    }

    public function locationToStage (x :Number, y :Number, z :Number) :Point
    {
        var roomCoord :Point = locationToRoom(x, y, z);
        if (null != roomCoord) {
            return roomToStage(roomCoord);
        }

        return null;
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
     * <code>
     *    testHitPoint(x :Number, y :Number, shapeFlag :Boolean) :Boolean
     * </code>
     *
     * @see flash.display.DisplayObject#testHitPoint()
     */
    public function setHitPointTester (tester :Function) :void
    {
        _hitPointTester = tester;
    }

    /**
     * Returns the AVRG's currently configured hit point tester.
     *
     * @see #setHitPointTester()
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

    /**
     * Is this client in control?
     *
     * <p>Control is a mutually exclusive lock across all instances of the AVRG in a given
     * room (i.e. running in other browsers across the network). Only one client per room
     * can hold the lock at any time, and control is assigned automatically.</p>
     */
    public function hasControl () :Boolean
    {
        return callHostCode("hasControl_v1");
    }

    public function spawnMob (id :String, name :String) :Boolean
    {
        return callHostCode("spawnMob_v1", id, name);
    }

    public function despawnMob (id :String) :Boolean
    {
        return callHostCode("despawnMob_v1", id);
    }

    public function getAvatarInfo (playerId :int) :AVRGameAvatar
    {
        var data :Array = callHostCode("getAvatarInfo_v1", playerId);
        if (data == null) {
            return null;
        }
        var ix :int = 0;
        var info :AVRGameAvatar = new AVRGameAvatar();
        info.name = data[ix ++];
        info.state = data[ix ++];
        info.x = data[ix ++];
        info.y = data[ix ++];
        info.z = data[ix ++];
        info.orientation = data[ix ++];
        info.moveSpeed = data[ix ++];
        info.isMoving = data[ix ++];
        info.isIdle = data[ix ++];
        info.stageBounds = data[ix ++];
        return info;
    }

    public function playAvatarAction (action :String) :Boolean
    {
        return callHostCode("playAvatarAction_v1", action);
    }

    public function setAvatarState (state :String) :Boolean
    {
        return callHostCode("setAvatarState_v1", state);
    }

    public function setAvatarMoveSpeed (pixelsPerSecond :Number) :Boolean
    {
        return callHostCode("setAvatarMoveSpeed_v1", state);
    }

    public function setAvatarLocation (x :Number, y :Number, z: Number, orient :Number) :Boolean
    {
        return callHostCode("setAvatarLocation_v1", state);
    }

    public function setAvatarOrientation (orient :Number) :Boolean
    {
        return callHostCode("setAvatarOrientation_v1", state);
    }

    /**
     * Start the ticker with the specified name. The ticker will deliver messages
     * to all connected clients, at the specified delay. The value of each message is
     * a single integer, starting with 0 and increasing by 1 with each messsage.
     */
    public function startTicker (tickerName :String, msOfDelay :int) :void
    {
        callHostCode("setTicker_v1", tickerName, msOfDelay);
    }

    /**
     * Stop the specified ticker.
     */
    public function stopTicker (tickerName :String) :void
    {
        startTicker(tickerName, 0);
    }

    /** @private */
    override protected function setUserProps (o :Object) :void
    {
        super.setUserProps(o);

        o["gotControl_v1"] = gotControl_v1;
        o["hitTestPoint_v1"] = hitTestPoint_v1;
        o["panelResized_v1"] = panelResized_v1;
        o["coinsAwarded_v1"] = coinsAwarded_v1;

        o["playerLeft_v1"] = playerLeft_v1;
        o["playerEntered_v1"] = playerEntered_v1;
        o["leftRoom_v1"] = leftRoom_v1;
        o["enteredRoom_v1"] = enteredRoom_v1;

        o["requestMobSprite_v1"] = requestMobSprite_v1;
        o["mobRemoved_v1"] = mobRemoved_v1;
        o["mobAppearanceChanged_v1"] = mobAppearanceChanged_v1;

        o["actorStateSet_v1"] = actorStateSet_v1;
        o["actorAppearanceChanged_v1"] = actorAppearanceChanged_v1;
    }

    /** @private */
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

    /** @private */
    protected function mobRemoved_v1 (id :String) :void
    {
        Log.getLog(this).debug("Nuking control [id=" + id + "]");
        delete _mobs[id];
    }

    /** @private */
    protected function mobAppearanceChanged_v1 (
        id :String, locArray :Array, orient :Number, moving :Boolean, idle :Boolean) :void
    {
        var entry :MobEntry = _mobs[id];
        if (entry) {
            entry.control.appearanceChanged(locArray, orient, moving, idle);
        }
    }

    /** @private */
    protected function hitTestPoint_v1 (x :Number, y :Number, shapeFlag :Boolean) :Boolean
    {
        return _hitPointTester != null && _hitPointTester(x, y, shapeFlag);
    }

    /** @private */
    protected function coinsAwarded_v1 (amount :int) :void
    {
        dispatch(new AVRGameControlEvent(AVRGameControlEvent.COINS_AWARDED, null, amount));
    }

    /** @private */
    protected function gotControl_v1 () :void
    {
        dispatch(new AVRGameControlEvent(AVRGameControlEvent.GOT_CONTROL));
    }

    /** @private */
    protected function playerLeft_v1 (id :int) :void
    {
        dispatch(new AVRGameControlEvent(AVRGameControlEvent.PLAYER_LEFT, null, id));
    }

    /** @private */
    protected function playerEntered_v1 (id :int) :void
    {
        dispatch(new AVRGameControlEvent(AVRGameControlEvent.PLAYER_ENTERED, null, id));
    }

    /** @private */
    protected function playerMoved_v1 (id :int) :void
    {
        dispatch(new AVRGameControlEvent(AVRGameControlEvent.PLAYER_MOVED, null, id));
    }

    /** @private */
    protected function leftRoom_v1 () :void
    {
        dispatch(new AVRGameControlEvent(AVRGameControlEvent.LEFT_ROOM));
    }

    /** @private */
    protected function enteredRoom_v1 (newScene :int) :void
    {
        dispatch(new AVRGameControlEvent(AVRGameControlEvent.ENTERED_ROOM, null, newScene));
    }

    /** @private */
    protected function panelResized_v1 () :void
    {
        dispatch(new AVRGameControlEvent(AVRGameControlEvent.SIZE_CHANGED));
    }

    /** @private */
    protected function actorAppearanceChanged_v1 (playerId :int) :void
    {
        dispatch(new AVRGameControlEvent(AVRGameControlEvent.AVATAR_CHANGED, null, playerId));
    }

    /** @private */
    protected function actorStateSet_v1 (playerId :int, state :String) :void
    {
        dispatch(new AVRGameControlEvent(AVRGameControlEvent.AVATAR_CHANGED, null, playerId));
    }

    /** @private */
    override protected function createSubControls () :Array
    {
        return [
            _state = new StateControl(this),
            _quests = new QuestControl(this)
        ];
    }

    /** @private */
    protected var _quests :QuestControl;
    /** @private */
    protected var _state :StateControl;

    /** @private */
    protected var _mobSpriteExporter :Function;
    /** @private */
    protected var _hitPointTester :Function;

    /** @private */
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
