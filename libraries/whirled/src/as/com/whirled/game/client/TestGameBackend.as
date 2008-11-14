//
// $Id$

package com.whirled.game.client {

import flash.display.DisplayObject;

import com.threerings.crowd.util.CrowdContext;
import com.threerings.util.MessageBundle;
import com.whirled.game.data.WhirledGameObject;

/**
 * Extends the standard backend with some useful bits for debugging a user game.
 */
public class TestGameBackend extends WhirledGameBackend
{
    public function TestGameBackend (
        ctx :CrowdContext, gameObj :WhirledGameObject, ctrl :TestGameController)
    {
        super(ctx, gameObj, ctrl);
    }

    // from BaseGameBackend
    override protected function reportGameError (msg :String, err :Error = null) :void
    {
        super.reportGameError(msg, err);

        // in the text environment we also report the stack trace to the chat
        if (err != null) {
            (_ctx as CrowdContext).getChatDirector().displayAttention(
                null, MessageBundle.taint(err.getStackTrace()));
        }
    }

    // from WhirledGameBackend
    override protected function getHeadShot_v2 (occupant :int) :DisplayObject
    {
        validateConnected();

        var isFirstOccupant :Boolean = _gameObj.occupants.size() > 0 &&
                                       _gameObj.occupants.get(0) == occupant;

        // return one of two dummy headshots, for testing purposes
        return new HeadSpriteShim(isFirstOccupant ? new HEADSHOT_1() : new HEADSHOT_2());
    }

    // Embed some media to be used as default headshots
    [Embed(source="../../../../../../rsrc/images/headshots/natto.png")]
    protected static const HEADSHOT_1 :Class;
    [Embed(source="../../../../../../rsrc/images/headshots/weardd.png")]
    protected static const HEADSHOT_2 :Class;
}

}

import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.display.BitmapData;
import flash.display.Bitmap;
import flash.geom.Point;

class HeadSpriteShim extends Sprite
{
    public function HeadSpriteShim (headshot :DisplayObject = null)
    {
        if (headshot != null) {
            headshot.x = (WIDTH - headshot.width) * 0.5;
            headshot.y = (HEIGHT - headshot.height) * 0.5;
            super.addChild(headshot);
        }
    }

    override public function get width () :Number
    {
        return WIDTH * scaleX;
    }

    override public function set width (newVal :Number) :void
    {
        scaleX = newVal / WIDTH;
    }

    override public function get height () :Number
    {
        return HEIGHT * scaleY;
    }

    override public function set height (newVal :Number) :void
    {
        scaleY = newVal / HEIGHT;
    }

    override public function addChild (child :DisplayObject) :DisplayObject
    {
        nope();
        return null;
    }

    override public function addChildAt (child :DisplayObject, index :int) :DisplayObject
    {
        nope();
        return null;
    }

    override public function contains (child :DisplayObject) :Boolean
    {
        return (child == this); // make it only work for us..
    }

    override public function getChildAt (index :int) :DisplayObject
    {
        return null;
    }

    override public function getChildByName (name :String) :DisplayObject
    {
        return null;
    }

    override public function getChildIndex (child :DisplayObject) :int
    {
        return -1;
    }

    override public function getObjectsUnderPoint (point :Point) :Array
    {
        return [];
    }

    override public function removeChild (child :DisplayObject) :DisplayObject
    {
        nope();
        return null;
    }

    override public function removeChildAt (index :int) :DisplayObject
    {
        nope();
        return null;
    }

    override public function setChildIndex (child :DisplayObject, index :int) :void
    {
        nope();
    }

    override public function swapChildren (child1 :DisplayObject, child2 :DisplayObject) :void
    {
        nope();
    }

    override public function swapChildrenAt (index1 :int, index2 :int) :void
    {
        nope();
    }

    protected function nope () :void
    {
        throw new Error("Operation not permitted.");
    }

    protected static const WIDTH :int = 80;
    protected static const HEIGHT :int = 60;
}
