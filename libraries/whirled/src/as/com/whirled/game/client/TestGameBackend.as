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

        // return one of two dummy headshots, for testing purposes
        var isFirstOccupant :Boolean = _gameObj.occupants.size() > 0 &&
                                       _gameObj.occupants.get(0) == occupant;
        var shot :DisplayObject = isFirstOccupant ? new HEADSHOT_1() : new HEADSHOT_2();
        shot.x = (HeadShot.WIDTH - shot.width) / 2;
        shot.y = (HeadShot.HEIGHT - shot.height) / 2;
        return new HeadShot(shot);
    }

    // Embed some media to be used as default headshots
    [Embed(source="../../../../../../rsrc/images/headshots/natto.png")]
    protected static const HEADSHOT_1 :Class;
    [Embed(source="../../../../../../rsrc/images/headshots/weardd.png")]
    protected static const HEADSHOT_2 :Class;
}
}
