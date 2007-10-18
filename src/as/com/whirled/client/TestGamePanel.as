//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.client {

import flash.geom.Rectangle;

import com.threerings.crowd.data.PlaceObject;
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
    }

    override public function willEnterPlace (plobj :PlaceObject) :void
    {
        super.willEnterPlace(plobj);

        _gameView.percentWidth = 80;

        _playerList = new PlayerList();
        _playerList.x = 700;
        addChild(_playerList);
        _playerList.startup(plobj);
    }

    override public function didLeavePlace (plobj :PlaceObject) :void
    {
        super.didLeavePlace(plobj);

        _playerList.shutdown();
        removeChild(_playerList);
        _playerList = null;
    }

    public function getStageBounds () :Rectangle
    {
        // in test mode games have the entire width and height of the stage
        return new Rectangle(0, 0, stage.stageWidth - 200, stage.stageHeight);
    }

    override protected function createBackend () :GameControlBackend
    {
        return new TestGameControlBackend(_ctx, _ezObj, _ctrl as TestGameController, this);
    }


    protected var _playerList :PlayerList;
}
}
