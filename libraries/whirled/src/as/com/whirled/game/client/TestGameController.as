//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.client {

import com.threerings.crowd.client.PlaceView;
import com.threerings.crowd.util.CrowdContext;

/**
 * Wires up the necessary backend bits for testing games.
 */
public class TestGameController extends WhirledGameController
{
    // from BaseGameController
    override public function backToWhirled (showLobby :Boolean = false) :void
    {
        // just log-off, either way
        _ctx.getClient().logoff(false);
    }

    // from PlaceController
    override protected function createPlaceView (ctx :CrowdContext) :PlaceView
    {
        return new TestGamePanel(ctx, this);
    }
}
}
