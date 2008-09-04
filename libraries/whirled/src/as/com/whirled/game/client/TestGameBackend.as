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
}
}
