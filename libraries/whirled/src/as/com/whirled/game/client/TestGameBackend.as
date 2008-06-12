//
// $Id$

package com.whirled.game.client {

import com.threerings.util.MessageBundle;

import com.threerings.crowd.util.CrowdContext;

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

    override protected function logGameError (msg :String, err :Error = null) :void
    {
        super.logGameError(msg, err);

        // also, to aid testing, spew it to the chat
        displayInfo(null, MessageBundle.taint("Game error: " + msg));
        if (err != null) {
            displayInfo(null, MessageBundle.taint(err.getStackTrace()));
        }
    }
}
}
