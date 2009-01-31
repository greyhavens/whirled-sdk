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

    // from BaseGameBackend
    override public function entryAdded (event :EntryAddedEvent) :void
    {
        var name :String = event.getName();
        if (name == PlaceObject.OCCUPANT_INFO) {
            var occInfo :OccupantInfo = (event.getEntry() as OccupantInfo);
            if (isPlayer(occInfo.username)) {
                _somgr.subscribe(occInfo.bodyOid, subscribedToPlayer);
            }
        }

        super.entryAdded(event);
    }

    // from BaseGameBackend
    override public function entryUpdated (event :EntryUpdatedEvent) :void
    {
        var name :String = event.getName();
        if (name == PlaceObject.OCCUPANT_INFO) {
            var occInfo :WhirledGameOccupantInfo = (event.getEntry() as WhirledGameOccupantInfo);
            var oldInfo :WhirledGameOccupantInfo = (event.getOldEntry() as WhirledGameOccupantInfo);
            // Only report someone else if they transitioned from uninitialized to initialized
            // Note that our own occupantInfo will never pass this test, that is correct.
            if (!isInited(oldInfo) && super.isInited(occInfo)) {
                _somgr.subscribe(occInfo.bodyOid, subscribedToPlayer);
            }
        }

        super.entryUpdated(event);
    }

    // from BaseGameBackend
    override public function entryRemoved (event :EntryRemovedEvent) :void
    {
        var name :String = event.getName();
        if (name == PlaceObject.OCCUPANT_INFO) {
            var occInfo :WhirledGameOccupantInfo = (event.getOldEntry() as WhirledGameOccupantInfo);
            if (isInited(occInfo) && isPlayer(occInfo.username)) {
                _somgr.unsubscribe(occInfo.bodyOid);
            }
        }

        super.entryRemoved(event);
    }

    // from BaseGameBackend
    override public function elementUpdated (event :ElementUpdatedEvent) :void
    {
        var name :String = event.getName();
        if (name == GameObject.PLAYERS) {
            var oldPlayer :Name = (event.getOldValue() as Name);
            var newPlayer :Name = (event.getValue() as Name);
            var occInfo :OccupantInfo;
            if (oldPlayer != null) {
                occInfo = _gameObj.getOccupantInfo(oldPlayer);
                if (isInited(occInfo)) {
                    _somgr.unsubscribe(occInfo.bodyOid);
                }
            }
            if (newPlayer != null) {
                occInfo = _gameObj.getOccupantInfo(newPlayer);
                if (super.isInited(occInfo)) {
                    _somgr.subscribe(occInfo.bodyOid, function (...ignored) :void {
                        occupantRoleChanged(occInfo, true);
                    });
                }
            }
        }

        super.elementUpdated(event);
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
    override protected function playerOwnsData (type :int, ident :String, playerId :int) :Boolean
    {
        if (playerId == CURRENT_USER) {
            throw new Error("Server agent has no current user");
        }

        var cfg :ThaneGameConfig = _ctrl.getConfig();
        var player :WhirledPlayerObject = getPlayer(playerId) as WhirledPlayerObject;
        if (player == null) {
            log.warning("Player " + playerId + " not found");
            return false;
        }
        return player.ownsGameContent(cfg.getGameId(), type, ident)
    }

    // from BaseGameBackend
    override protected function isInited (occInfo :OccupantInfo) :Boolean
    {
        return super.isInited(occInfo) && getPlayer(occInfo.bodyOid) != null;
    }

    protected function subscribedToPlayer (player :WhirledPlayerObject) :void
    {
        var occInfo :OccupantInfo = _gameObj.getOccupantInfo(player.username);
        if (isInited(occInfo)) {
            occupantAdded(occInfo);
            if (!_gameStarted && _gameObj.isInPlay()) {
                gameStateChanged(true);
            }
        }
    }

    protected var _ctrl :ThaneGameController;

    protected var _somgr :SafeObjectManager;
}
}

