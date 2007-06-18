//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.client {

import com.threerings.crowd.client.PlaceView;
import com.threerings.crowd.util.CrowdContext;
import com.threerings.ezgame.client.EZGameController;

/**
 * Wires up the necessary backend bits for testing games.
 */
public class TestGameController extends EZGameController
{
    public function getAvailableFlow () :int
    {
        return 100; // TOBEDOOBIEDOO
    }

    public function awardFlow (amount :int) :void
    {
        // nada
    }

    // from PlaceController
    override protected function createPlaceView (ctx :CrowdContext) :PlaceView
    {
        return new TestGamePanel(ctx, this);
    }
}
}
