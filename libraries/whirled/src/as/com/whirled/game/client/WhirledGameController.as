//
// $Id$

package com.whirled.game.client {

import flash.events.Event;

import com.threerings.util.Name;

import com.threerings.presents.dobj.AttributeChangedEvent;
import com.threerings.presents.dobj.SetListener;
import com.threerings.presents.dobj.EntryAddedEvent;
import com.threerings.presents.dobj.EntryRemovedEvent;
import com.threerings.presents.dobj.EntryUpdatedEvent;

import com.threerings.crowd.client.PlaceView;
import com.threerings.crowd.data.BodyObject;
import com.threerings.crowd.data.PlaceConfig;
import com.threerings.crowd.data.PlaceObject;
import com.threerings.crowd.util.CrowdContext;

import com.threerings.parlor.game.client.GameController;
import com.threerings.parlor.game.data.GameConfig;
import com.threerings.parlor.game.data.GameObject;

import com.threerings.parlor.turn.client.TurnGameController;
import com.threerings.parlor.turn.client.TurnGameControllerDelegate;

import com.whirled.game.data.WhirledGameObject;

/**
 * A controller for flash games.
 */
public class WhirledGameController extends GameController
    implements TurnGameController, SetListener
{
    public function WhirledGameController ()
    {
        addDelegate(_turnDelegate = new TurnGameControllerDelegate(this));
    }

    /**
     * This is called by the GameBackend once it has initialized and made contact with usercode.
     */
    public function userCodeIsConnected (autoReady :Boolean) :void
    {
        // Every occupant should call occupntInRoom, but if we end up calling playerReady()
        // then that suffices.
        if (autoReady) {
            var bobj :BodyObject = (_ctx.getClient().getClientObject() as BodyObject);
            var isPlayer :Boolean = (_gconfig.getMatchType() == GameConfig.PARTY) || 
                (_gobj.getPlayerIndex(bobj.getVisibleName()) != -1);
            if (isPlayer) {
                playerIsReady();
                return;
            }
            // else, we're not a player, so fall through...
        }

        // either we're just an observer, or autoReady is false
        _gobj.manager.invoke("occupantInRoom");
    }

    /**
     */
    public function backToWhirled (showLobby :Boolean = false) :void
    {
        // do nothing by default
    }

    /**
     * Called by the GameBackend when the game is ready to start. If the game has ended, this can
     * be called by all clients to start the game anew.
     */
    public function playerIsReady () :void
    {
        playerReady();
    }

    // from PlaceController
    override public function willEnterPlace (plobj :PlaceObject) :void
    {
        _gameObj = (plobj as WhirledGameObject);

        super.willEnterPlace(plobj);
    }

    // from PlaceController
    override public function didLeavePlace (plobj :PlaceObject) :void
    {
        super.didLeavePlace(plobj);

        _gameObj = null;
    }

    // from TurnGameController
    public function turnDidChange (turnHolder :Name) :void
    {
        _panel.backend.turnDidChange();
    }

    // from GameController
    override protected function shouldAutoPlayerReady (bobj :BodyObject) :Boolean
    {
        // we don't want to auto-player ready in willEnterPlace(), we'll do it ourselves after the
        // client code has connected
        return false;
    }

    // from GameController
    override public function attributeChanged (event :AttributeChangedEvent) :void
    {
        var name :String = event.getName();
        if (WhirledGameObject.CONTROLLER_OID == name) {
            _panel.backend.controlDidChange();
        } else if (GameObject.ROUND_ID == name) {
            if ((event.getValue() as int) > 0) {
                _panel.backend.roundStateChanged(true);
            } else {
                _panel.backend.roundStateChanged(false);
            }
        } else {
            super.attributeChanged(event);
        }
    }

    // from SetListener
    public function entryAdded (event :EntryAddedEvent) :void
    {
        if (event.getName() == PlaceObject.OCCUPANT_INFO) {
            _panel.checkRematchVisibility();
        }
    }

    // from SetListener
    public function entryRemoved (event :EntryRemovedEvent) :void
    {
        if (event.getName() == PlaceObject.OCCUPANT_INFO) {
            _panel.checkRematchVisibility();
        }
    }

    // from SetListener
    public function entryUpdated (event :EntryUpdatedEvent) :void
    {
        // nada
    }

    // from GameController
    override protected function gameDidStart () :void
    {
        super.gameDidStart();
        _panel.backend.gameStateChanged(true);
        _panel.checkRematchVisibility();
    }

    // from GameController
    override protected function gameDidEnd () :void
    {
        super.gameDidEnd();
        _panel.backend.gameStateChanged(false);
        _panel.checkRematchVisibility();
    }

    // from PlaceController
    override protected function createPlaceView (ctx :CrowdContext) :PlaceView
    {
        return new WhirledGamePanel(ctx, this);
    }

    // from PlaceController
    override protected function didInit () :void
    {
        super.didInit();

        // we can't just assign _panel in createPlaceView() for some exciting reason
        _panel = (_view as WhirledGamePanel);
    }

    protected var _gameObj :WhirledGameObject;
    protected var _turnDelegate :TurnGameControllerDelegate;
    protected var _panel :WhirledGamePanel;
}
}
