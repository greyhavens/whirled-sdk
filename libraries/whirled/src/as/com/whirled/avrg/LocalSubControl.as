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
 * @see #getPaintableArea()
 */
[Event(name="sizeChanged", type="com.whirled.avrg.AVRGameControlEvent")]

/**
 * TEMPORARY. This event will be removed soon, and <b>no backwards compatibility will be
 * provided</b>. Use at your own risk. Better yet, don't use it at all, unless you are
 * wearing Tim Conkling's underwear.
 *
 * Dispatched when any party information has changed.
 */
[Event(name="partyChanged", type="com.whirled.avrg.AVRGameControlEvent")]

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

//    /**
//     * Return a Rectangle defining the paintable area of the AVRG media on this client.
//     * This will be in "screen" coordinates and this Rectangle should always start at 0,0.
//     */
//    public function getPaintableArea () :Rectangle
//    {
//    }
//
//    // event: PAINTABLE_SIZE_CHANGED
//
//    /**
//     * Return a Rectangle defining the paintable area that is on-screen on this client.
//     * This will be a sub-rectangle of getPaintableArea(), in the same coordinate system.
//     */
//    public function getVisiblePaintableArea () :Rectangle
//    {
//    }
//
//    // event: SCREEN_AREA_CHANGED
//
//    /**
//     * Return a Rectangle defining the paintable area that is over the "room".
//     * Drawing in all other areas but this Rectangle allows you to "theme" the client a bit.
//     */
//    public function getRoomPaintableArea () :Rectangle
//    {
//    }
//
//    // event: ROOM_AREA_CHANGED

    /**
     * Get the room bounds in "room pixels".
     * This will be a 3-element array corresponding to [ width, height, depth ].
     * These values are *not* real pixels. Rather, if an avatar is 100 pixels wide
     * and a room is 700 pixels wide, then the avatar should be able to span 7 across, whether
     * it's in the front of the room or the rear.
     *
     * TODO: This is not yet here. It's @private.
     */
    public function getRoomBounds () :Array
    {
        return callHostCode("getRoomBounds_vRay") as Array;
    }

//
//    /**
//     * Turn a logical room coordinate into a screen coordinate.
//     */
//    public function locationToPaintable (array :Array) :Point
//    {
//    }
//
//    /**
//     * Turn a screen coordinate back into a logical room coordinate.
//     */
//    public function paintableToLocationAtDepth (p :Point, depth :Number = 1) :Array
//    {
//    }
//
//    /**
//     * Turn a screen coordinate back into a logical room coordinate.
//     */
//    public function paintableToLocationAtHeight (p :Point, height :Number = 0) :Array
//    {
//    }

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
     * @see #event:SizeChanged
     */
    public function getPaintableArea (full :Boolean = true) :Rectangle
    {
        return Rectangle(callHostCode("getPaintableArea_v1", full));
    }

    /**
     * TEMPORARY. This method will be removed soon, and <b>no backwards compatibility will be
     * provided</b>. Use at your own risk. Better yet, don't use it at all, unless you are
     * wearing Tim Conkling's underwear.
     *
     * Get the party information of the local player, or null if they're not in a party.
     * {
     *     id: <partyId> (int)
     *     name: <partyName> (String)
     *     leaderId: <playerId> (int)
     *     players: <playerIds> (Array of ints)
     * }
     */
    public function getPartyInfo () :Object
    {
        return callHostCode("getPartyInfo_temp") as Object;
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
     * Finds the projection of mouse coordinates onto a plane in the room, parallel with the
     * front wall, intersecting the room at specified depth. This type of functionality is useful
     * for converting mouse position into room position at some constant depth. The result is
     * not constrained to be inside the room unit box.
     *
     *   @param p            location in room coordinate space
     *   @param depth        Z position of the intersection wall, in room coordinate space.
     *
     *   @return an array containing [ x, y, z ] (with z value equal to depth), or null
     *   if no valid location was found.
     */
    public function roomToLocationAtDepth (p :Point, depth :Number) :Array
    {
        return callHostCode("roomToLocationAtDepth_v1", p, depth);
    }

     /**
     * Finds the projection of mouse coordinates onto a plane in the room, parallel with the
     * floor, intersecting the room at specified height. This type of functionality is useful
     * for converting mouse position into room position at some constant height. The result is
     * not constrained to be inside the room unit box.
     *
     *   @param p            location in room coordinate space
     *   @param height       Y position of the intersection wall, in room coordinate space.
     *
     * @return an array containing [ x, y, z ] (with y value equal to height) or null if
     * no valid location was found.
     *
     */
    public function roomToLocationAtHeight (p :Point, height :Number) :Array
    {
        return callHostCode("roomToLocationAtHeight_v1", p, height);
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
     * @see flash.display.DisplayObject#hitTestPoint()
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
     * when mobs are spawned by the server agent. The function must take the string type of the
     * requested mob and return a <code>DisplayObject</code>:
     *
     * <listing version="3.0">
     *    function createMobSprite (type :String) :DisplayObject;
     * </listing>
     *
     * <p>Once created, the mob will be drawn in the room until the server agent despawns it. Clients
     * should not attempt to remove the sprite. Each mob in a room has a corresponding
     * <code>MobSubControlClient</code>. Games that use mobs should call this function during
     * initialization so that if the player is joining an in-progress game, all the previously
     * spawned mobs will be created.</p>
     *
     * @see RoomSubControlServer#spawnMob()
     * @see RoomSubControlClient#getMobSubControl()
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
    
    /**
     * Instructs the game client to open the game invite page, allowing the player to invite friends
     * to play this game.
     * @param defmsg Default message that will be included along with the game's URL when sent
     * to the player's friends.
     * @param token Optional token that will be included on the URL and eventually passed back to
     * the game when an invited friend goes to the URL.  This allows the game to start in
     * a different state than usual.
     */ 
    public function showInvitePage (defmsg :String, token :String = "") :void
    {
        callHostCode("showInvitePage_v1", defmsg, token);
    }
    
    /**
     * Retrieves the token, if any, that was used to launch the game.  If the player entered into
     * the game via a URL that contained a token (provided by the game via showInvitePage), this
     * will return that token, otherwise null. Note that the invitations are not managed securely,
     * it would be trivial for someone to modify a URL to specify a different token, so appropriate
     * checks should be made.
     */
    public function getInviteToken () :String
    {
        return callHostCode("getInviteToken_v1");
    }
    
    /**
     * Retrieves the ID of the member who invited the current player to this game (using the page
     * shown by <code>showInvitePage</code>. Returns 0 if the player did not start the game via an
     * invite link.
     */
    public function getInviterMemberId () :int
    {
    	return callHostCode("getInviterMemberId_v1");
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
        o["partyChanged_temp"] = partyChanged_temp;
    }

    /** @private */
    protected function panelResized_v1 () :void
    {
        dispatch(new AVRGameControlEvent(AVRGameControlEvent.SIZE_CHANGED));
    }

    protected function partyChanged_temp () :void
    {
        dispatch(new AVRGameControlEvent("partyChanged"));
    }

    /** @private */
    protected var _mobSpriteExporter :Function;

    /** @private */
    protected var _hitPointTester :Function;
}
}
