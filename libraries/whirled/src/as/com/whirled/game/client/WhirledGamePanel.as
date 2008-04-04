//
// $Id$

package com.whirled.game.client {

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Loader;

import flash.events.Event;

import flash.utils.Dictionary;

import mx.containers.Canvas;

import mx.core.Container;
import mx.core.IChildList;

import com.threerings.util.Name;

import com.threerings.flash.MediaContainer;

import com.threerings.flex.CommandButton;
import com.threerings.flex.CommandLinkButton;

import com.threerings.crowd.client.PlaceView;
import com.threerings.crowd.data.OccupantInfo;
import com.threerings.crowd.data.PlaceObject;
import com.threerings.crowd.util.CrowdContext;

import com.threerings.parlor.game.data.GameConfig;

import com.whirled.game.data.WhirledGameConfig;
import com.whirled.game.data.WhirledGameObject;

public class WhirledGamePanel extends Canvas
    implements PlaceView
{
    /** The game object backend. */
    public var backend :GameBackend;

    public function WhirledGamePanel (ctx :CrowdContext, ctrl :WhirledGameController)
    {
        _ctx = ctx;
        _ctrl = ctrl;

        _backToLobby = new CommandLinkButton();
        _backToWhirled = new CommandLinkButton();
        _rematch = new CommandButton();
        _rematch.toggle = true;
        _rematch.setCallback(handleRematchClicked);

        _playerList = createPlayerList();
    }

    // from PlaceView
    public function willEnterPlace (plobj :PlaceObject) :void
    {
        // Important: The playerList needs to be a listener before the backend..
        _playerList.startup(plobj);

        var cfg :WhirledGameConfig = (_ctrl.getPlaceConfig() as WhirledGameConfig);

        _gameObj = (plobj as WhirledGameObject);
        backend = createBackend();

        _gameView = new GameContainer(cfg.getGameDefinition().getMediaPath(cfg.getGameId()));
        configureGameView(_gameView);
        backend.setSharedEvents(
            Loader(_gameView.getMediaContainer().getMedia()).contentLoaderInfo.sharedEvents);
        backend.setContainer(_gameView);
        addChild(_gameView);


        var labels :Array = getButtonLabels(plobj);
        _backToWhirled.label = labels[0];
        _backToLobby.label = labels[1];
        _rematch.label = labels[2];

        _backToWhirled.setCallback((_ctrl as WhirledGameController).backToWhirled, false);
        _backToLobby.setCallback((_ctrl as WhirledGameController).backToWhirled, true);
        checkRematchVisibility();
    }

    // from PlaceView
    public function didLeavePlace (plobj :PlaceObject) :void
    {
        _playerList.shutdown();

        _gameView.getMediaContainer().shutdown(true);
        removeChild(_gameView);

        backend.shutdown();
    }

    /**
     * Get a handle on the player list.
     */
    public function getPlayerList () :PlayerList
    {
        return _playerList;
    }

    /**
     * Set whether or not we show some of the standard buttons.
     */
    public function setShowButtons (
        rematch :Boolean, backToLobby :Boolean, backToWhirled :Boolean) :void
    {
        _showRematch = rematch;
        checkRematchVisibility();
        _backToLobby.visible = backToLobby;
        _backToLobby.includeInLayout = backToLobby;
        _backToWhirled.visible = backToWhirled;
        _backToWhirled.includeInLayout = backToWhirled;
    }

    /**
     * Called by the controller and internally to update the visibility of the rematch button.
     */
    public function checkRematchVisibility () :void
    {
        // only show the rematch button if it's been configured to be on, the game is over,
        // has been in a round before, and we're NOT a party game
        var canRematch :Boolean = _showRematch && !_gameObj.isInPlay() && (_gameObj.roundId != 0) &&
            ((_ctrl.getPlaceConfig() as WhirledGameConfig).getMatchType() != GameConfig.PARTY) &&
            playersAllHere();
        _rematch.visible = canRematch;
        _rematch.includeInLayout = canRematch;

        if (_gameObj.isInPlay()) {
            // reset state
            _rematch.selected = false;
            _rematch.enabled = true;
        }
    }

    /**
     * Handle rematch being clicked. We prevent it from being clicked more than once.
     */
    protected function handleRematchClicked (... ignored) :void
    {
        _rematch.enabled = false;
        (_ctrl as WhirledGameController).playerIsReady();
    }

    /**
     * Return true if every player in the players array is present.
     */
    protected function playersAllHere () :Boolean
    {
        var occs :Array = _gameObj.occupantInfo.toArray();
        for each (var name :Name in _gameObj.players) {
            if (name != null) {
                var found :Boolean = false;
                for each (var occInfo :OccupantInfo in occs) {
                    if (name.equals(occInfo.username)) {
                        found = true;
                        break;
                    }
                }
                if (!found) {
                    return false;
                }
            }
        }
        return true;
    }

    /**
     * Get the labels for leave game, game lobby, rematch.
     */
    protected function getButtonLabels (plobj :PlaceObject) :Array /* of String */
    {
        throw new Error("abstract");
    }

    override protected function updateDisplayList (uw :Number, uh :Number) :void
    {
        super.updateDisplayList(uw, uh);

        if (backend != null) {
            backend.sizeChanged();
        }
    }

    /**
     * Creates the backend object that will handle requests from user code.
     */
    protected function createBackend () :GameBackend
    {
        return new GameBackend(_ctx, _gameObj, _ctrl);
    }

    /**
     * Creates the player list we'll use to display player names and scores.
     */
    protected function createPlayerList () :PlayerList
    {
        return new PlayerList();
    }

    protected function configureGameView (view :GameContainer) :void
    {
        view.percentWidth = 100;
        view.percentHeight = 100;
    }

    protected var _ctx :CrowdContext;
    protected var _ctrl :WhirledGameController;
    protected var _gameView :GameContainer;
    protected var _gameObj :WhirledGameObject;

    /** The player list. */
    protected var _playerList :PlayerList;

    /** Some buttons. */
    protected var _rematch :CommandButton;
    protected var _backToLobby :CommandLinkButton;
    protected var _backToWhirled :CommandLinkButton;

    /** Would we want to show the rematch button, if the game was over? */
    protected var _showRematch :Boolean = true;
}
}
