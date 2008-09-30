//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg {

import flash.geom.Point;
import flash.geom.Rectangle;

import com.whirled.AbstractControl;
import com.whirled.AbstractSubControl;

/**
 * Dispatched when the control has been resized.
 *
 * @eventType com.whirled.avrg.AVRGameControlEvent.SIZE_CHANGED
 */
[Event(name="sizeChanged", type="com.whirled.avrg.AVRGameControlEvent")]

/**
 * Defines actions, accessors and callbacks available on the client only.
 */
public class LocalSubControl extends AbstractSubControl
{
    /** @private */
    public function LocalSubControl (ctrl :AbstractControl)
    {
        super(ctrl);
    }

    /**
     * Displays a feedback chat message for the local player only, no other players or observers
     * will see it.
     */
    public function feedback (msg :String) :void
    {
        callHostCode("localChat_v1", msg);
    }

    /**
     * Returns the bounds of the area on which the AVRG will be drawn. This value changes when the
     * browser is resized, and when the player moves to another room. A null value may be returned
     * if the paintable area is not currently defined, for example if the player has left a room
     * and the new room is not yet loaded.
     *
     * @param full If true (the default), returns the entire paintable area. If false, returns the
     * area occupied by the room's decor, which can be smaller than the entire paintable area in
     * narrow rooms, or when the room view is zoomed out.
     *
     * @return a Rectangle containing the bounds of the paintable area, or null if the area is not
     * defined
     *
     * @see AVRGameControlEvent#SIZE_CHANGED
     */
    public function getPaintableArea (full :Boolean = true) :Rectangle
    {
        return Rectangle(callHostCode("getPaintableArea_v1", full));
    }

    // TODO: document
    public function paintableToRoom (p :Point) :Point
    {
        return callHostCode("stageToRoom_v1", p) as Point;
    }

    // TODO: document
    public function roomToPaintable (p :Point) :Point
    {
        return callHostCode("roomToStage_v1", p) as Point;
    }

    // TODO: document
    public function locationToRoom (x :Number, y :Number, z :Number) :Point
    {
        return callHostCode("locationToRoom_v1", x, y, z) as Point;
    }

    // TODO: document
    public function locationToPaintable (x :Number, y :Number, z :Number) :Point
    {
        var roomCoord :Point = locationToRoom(x, y, z);
        if (null != roomCoord) {
            return roomToPaintable(roomCoord);
        }

        return null;
    }

    /**
     * Configures the AVRG with a function to call to determine which pixels are alive for mouse
     * purposes and which are not. By default, all non-transparent pixels will capture the mouse.
     * The prototype for this method is identical to what the Flash API establishes in
     * <code>DisplayObject</code>:
     *
     * <listing version="3.0">
     *    function testHitPoint(x :Number, y :Number, shapeFlag :Boolean) :Boolean
     * </listing>
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

    /**
     * Sets the function that will manufacture <code>DisplayObject</code> instances on the client
     * when they are spawned by the server agent. The function must take the string type of the
     * requested mob and return a <code>DisplayObject</code>:
     * 
     * <listing version="3.0">
     *    function createMobSprite (type :String) :DisplayObject;
     * </listing>
     *
     * Once created, the mob will be drawn in the room until the server agent despawns it. Clients
     * should not attempt to remove the sprite. Each mob in a room has a corresponding
     * <code>MobSubControl</code>. Games that use mobs should call this function during
     * initialization so that if the player is joining an in-progress game, all the previously
     * spawned mobs will be created.
     *
     * @see RoomServerSubControl#spawnMob()
     * @see RoomServerSubControl#despawnMob()
     * @see RoomBaseSubControl#getSpawnedMobs()
     * @see RoomSubControl#getMobSubControl()
     * @see MobSubControl
     * @see http://wiki.whirled.com/Mobs
     */
    public function setMobSpriteExporter (exporter :Function) :void
    {
        _mobSpriteExporter = exporter;
    }

    /**
     * Accesses the previously set mob sprite exporter.
     * @see #setMobSpriteExporter()
     */
    public function get mobSpriteExporter () :Function
    {
        return _mobSpriteExporter;
    }

    /** @private */
    protected function hitTestPoint_v1 (x :Number, y :Number, shapeFlag :Boolean) :Boolean
    {
        return _hitPointTester != null && _hitPointTester(x, y, shapeFlag);
    }

    /** @private */
    override protected function setUserProps (o :Object) :void
    {
        super.setUserProps(o);
        o["panelResized_v1"] = panelResized_v1;
        o["hitTestPoint_v1"] = hitTestPoint_v1;
    }

    /** @private */
    protected function panelResized_v1 () :void
    {
        dispatch(new AVRGameControlEvent(AVRGameControlEvent.SIZE_CHANGED));
    }

    /** @private */
    protected var _mobSpriteExporter :Function;

    /** @private */
    protected var _hitPointTester :Function;
}
}
