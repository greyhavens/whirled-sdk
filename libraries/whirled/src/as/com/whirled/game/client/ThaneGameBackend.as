//
// $Id$

package com.whirled.game.client {

import flash.utils.Dictionary;
import com.threerings.crowd.data.BodyObject;
import com.threerings.crowd.data.OccupantInfo;
import com.threerings.crowd.data.PlaceObject;
import com.threerings.parlor.game.data.GameObject;
import com.threerings.presents.dobj.ElementUpdatedEvent;
import com.threerings.presents.dobj.EntryAddedEvent;
import com.threerings.presents.dobj.EntryUpdatedEvent;
import com.threerings.presents.dobj.EntryRemovedEvent;
import com.threerings.presents.util.SafeObjectManager;
import com.threerings.presents.util.PresentsContext;
import com.threerings.util.Log;
import com.threerings.util.Name;
import com.whirled.game.data.BaseGameConfig;
import com.whirled.game.data.ThaneGameConfig;
import com.whirled.game.data.WhirledGameObject;
import com.whirled.game.data.WhirledGameOccupantInfo;
import com.whirled.game.data.WhirledPlayerObject;

/**
 * Manages the backend of the game on a thane client.
 */
public class ThaneGameBackend extends BaseGameBackend
{
    public function ThaneGameBackend (
        ctx :PresentsContext, gameObj :WhirledGameObject, ctrl :ThaneGameController)
    {
        super(ctx, gameObj);
        _ctrl = ctrl;
        _somgr = new SafeObjectManager(_ctx.getDObjectManager(), Log.getLog(this));

        for each (var id :* in getPlayersArray()) {
            if (id != 0) {
                _somgr.subscribe(id);
            }
        }
    }

    public function getConnectListener () :Function
    {
        return handleUserCodeConnect;
    }

    override public function shutdown () :void
    {
        super.shutdown();
        _somgr.unsubscribeAll();
    }

    override protected function getConfig () :BaseGameConfig
    {
        return _ctrl.getConfig();
    }

    //---- GameControl -----------------------------------------------------

    //---- .game -----------------------------------------------------------

    /** @inheritDoc */
    override protected function getMyId_v1 () :int
    {
        validateConnected();
        return SERVER_AGENT_ID;
    }

    // --------------------------

    protected function getPlayer (oid :int) :BodyObject
    {
        return _somgr.getObj(oid) as BodyObject;
    }

    // from BaseGameBackend
    override protected function countPlayerData (type :int, ident :String, playerId :int) :int
    {
        if (playerId == CURRENT_USER) {
            throw new Error("Server agent has no current user");
        }

        var cfg :ThaneGameConfig = _ctrl.getConfig();
        var player :WhirledPlayerObject = getPlayer(playerId) as WhirledPlayerObject;
        if (player == null) {
            log.warning("Player " + playerId + " not found");
            return 0;
        }
        return player.countGameContent(cfg.getGameId(), type, ident)
    }

    // from BaseGameBackend
    override protected function occupantAdded (info :OccupantInfo) :void
    {
        if (isPlayer(info.username)) {
            _somgr.subscribe(info.bodyOid, function (...ignored) :void {
                doOccupantAdded(info);
            });

        } else {
            doOccupantAdded(info);
        }
    }

    // from BaseGameBackend
    override protected function doOccupantAdded (info :OccupantInfo) :void
    {
        _addedOccupants.push(info.bodyOid);
        super.doOccupantAdded(info);
    }

    // from BaseGameBackend
    override protected function occupantRemoved (info :OccupantInfo) :void
    {
        if (isPlayer(info.username)) {
            _somgr.unsubscribe(info.bodyOid);
        }

        doOccupantRemoved(info);
    }

    // from BaseGameBackend
    override protected function doOccupantRemoved (info :OccupantInfo) :void
    {
        var idx :int = _addedOccupants.indexOf(info.bodyOid);
        if (idx >= 0) {
            _addedOccupants.splice(idx, 1);
            super.doOccupantRemoved(info);
        }
    }

    // from BaseGameBackend
    override protected function occupantRoleChanged (info :OccupantInfo, isPlayerNow :Boolean) :void
    {
        if (isPlayerNow) {
            _somgr.subscribe(info.bodyOid, function (...ignored) :void {
                doOccupantRoleChanged(info, true);
            });

        } else {
            doOccupantRoleChanged(info, false);
            _somgr.unsubscribe(info.bodyOid);
        }
    }

    // from BaseGameBackend
    override protected function doOccupantRoleChanged (
        info :OccupantInfo, isPlayerNow :Boolean) :void
    {
        if (_addedOccupants.indexOf(info.bodyOid) >= 0) {
            super.doOccupantRoleChanged(info, isPlayerNow);
        }
    }

    // from BaseGameBackend
    override protected function readyToStart () :Boolean
    {
        if (!super.readyToStart()) {
            return false;
        }

        for (var ii :int = 0; ii < _gameObj.players.length; ii++) {
            var occInfo :OccupantInfo = _gameObj.getOccupantInfo(_gameObj.players[ii] as Name);
            if (getPlayer(occInfo.bodyOid) == null) {
                return false;
            }
        }
        return true;
    }

    protected var _ctrl :ThaneGameController;

    protected var _somgr :SafeObjectManager;
    protected var _addedOccupants :Array = new Array();
}
}

