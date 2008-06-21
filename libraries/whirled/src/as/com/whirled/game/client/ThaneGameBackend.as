//
// $Id$

package com.whirled.game.client {

import flash.utils.Dictionary;
import com.threerings.crowd.data.BodyObject;
import com.threerings.crowd.data.OccupantInfo;
import com.threerings.presents.util.SafeObjectManager;
import com.threerings.presents.util.PresentsContext;
import com.threerings.util.Log;
import com.threerings.util.Name;
import com.whirled.game.data.WhirledGameObject;
import com.whirled.game.data.BaseGameConfig;

/**
 * Manages the backend of the game on a thane client.
 */
public class ThaneGameBackend extends BaseGameBackend
{
    /** Magic number for {@link #getMyId} to return. */
    public static const SERVER_AGENT_ID :int = int.MIN_VALUE;

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
    override protected function occupantAdded (occInfo :OccupantInfo) :void
    {
        super.occupantAdded(occInfo);

        // subscribe to the player object
        if (isPlayer(occInfo.username)) {
            _somgr.subscribe(occInfo.bodyOid);
        }
    }

    // from BaseGameBackend
    override protected function occupantRemoved (occInfo :OccupantInfo) :void
    {
        // unsubscribe from the player object
        if (isPlayer(occInfo.username)) {
            _somgr.unsubscribe(occInfo.bodyOid);
        }

        super.occupantAdded(occInfo);
    }

    override protected function occupantRoleChanged (
        occInfo :OccupantInfo, 
        isPlayerNow :Boolean) :void
    {
        super.occupantRoleChanged(occInfo, isPlayerNow);

        // subscribe if the occupant has become a player, otherwise unsubscribe
        if (isPlayerNow) {
            _somgr.subscribe(occInfo.bodyOid);

        } else {
            _somgr.unsubscribe(occInfo.bodyOid);
        }
    }

    protected var _ctrl :ThaneGameController;

    protected var _somgr :SafeObjectManager;
}
}

