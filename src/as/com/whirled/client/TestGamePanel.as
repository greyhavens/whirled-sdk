//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.client {

import flash.geom.Rectangle;

import mx.containers.VBox;

import com.threerings.crowd.data.PlaceObject;
import com.threerings.crowd.util.CrowdContext;

import com.threerings.flex.ChatControl;
import com.threerings.flex.ChatDisplayBox;

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

        // have us take up the entire size of our parent
        percentWidth = 100;
        percentHeight = 100;

        _playerList = new PlayerList();
        addChild(_playerList);

        var chat :ChatDisplayBox = new ChatDisplayBox(ctx);
        chat.percentWidth = 100;
        chat.percentHeight = 100;

        var control :ChatControl = new ChatControl(ctx);

        _chatBox = new VBox();
        _chatBox.addChild(chat);
        _chatBox.addChild(control);
        addChild(_chatBox);
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

    // from Container
    override protected function updateDisplayList (
        unscaledWidth :Number, unscaledHeight :Number) :void
    {
        const GAP :Number = 14;
        const SIDEBAR_WIDTH :Number = 300;

        _gameView.width = unscaledWidth - GAP - SIDEBAR_WIDTH;
        _gameView.height = unscaledHeight;
        _playerList.x = unscaledWidth - SIDEBAR_WIDTH;

        _chatBox.x = unscaledWidth - SIDEBAR_WIDTH;
        _chatBox.y = _playerList.y + _playerList.height + GAP;
        _chatBox.width = SIDEBAR_WIDTH - GAP;
        _chatBox.height = unscaledHeight - (GAP * 2) - _playerList.height;

        super.updateDisplayList(unscaledWidth, unscaledHeight);
    }

    protected var _playerList :PlayerList;

    protected var _chatBox :VBox;
}
}
