//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.client {

import flash.geom.Rectangle;

import com.threerings.crowd.data.PlaceObject;
import com.threerings.crowd.util.CrowdContext;

import com.threerings.ezgame.client.EZGamePanel;
import com.threerings.ezgame.client.GameContainer;
import com.threerings.ezgame.client.GameControlBackend;

/**
 * Handles the main game view for test games.
 */
public class TestGamePanel extends EZGamePanel
    implements WhirledGamePanel
{
    public function TestGamePanel (ctx :CrowdContext, ctrl :TestGameController)
    {
        super(ctx, ctrl);

        _playerList = new PlayerList();
        _playerList.x = 700;
        addChild(_playerList);
    }

    override public function willEnterPlace (plobj :PlaceObject) :void
    {
        // Important: we need to start the playerList prior to calling super, so that it
        // is added as a listener to the gameObject prior to the backend being created
        // and added as a listener. That way, when the ezgame hears about an occupantAdded
        // event, the playerList already knows about that player!
        _playerList.startup(plobj);

        super.willEnterPlace(plobj);
    }

    override public function didLeavePlace (plobj :PlaceObject) :void
    {
        _playerList.shutdown();

        super.didLeavePlace(plobj);
    }

    // from WhirledGamePanel
    public function getPlayerList () :PlayerList
    {
        return _playerList;
    }

    override protected function createBackend () :GameControlBackend
    {
        return new TestGameControlBackend(_ctx, _ezObj, _ctrl as TestGameController, this);
    }

    override protected function configureGameView (view :GameContainer) :void
    {
        // we don't call super because super sets percentWidth and percentHeight which fucks things
        // right on up; force games to 700x500 as that's what we want for whirled
        view.width = 700;
        view.height = 500;
    }

    protected var _playerList :PlayerList;
}
}
