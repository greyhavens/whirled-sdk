//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.client {

import flash.geom.Rectangle;

import com.threerings.crowd.util.CrowdContext;
import com.threerings.ezgame.client.EZGamePanel;
import com.threerings.ezgame.client.GameControlBackend;

/**
 * Handles the main game view for test games.
 */
public class TestGamePanel extends EZGamePanel
{
    public function TestGamePanel (ctx :CrowdContext, ctrl :TestGameController)
    {
        super(ctx, ctrl);
        trace("It is alive!");
    }

    public function getStageBounds () :Rectangle
    {
        // in test mode games have the entire width and height of the stage
        return new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
    }

    override protected function createBackend () :GameControlBackend
    {
        return new TestGameControlBackend(_ctx, _ezObj, _ctrl as TestGameController, this);
    }
}
}
