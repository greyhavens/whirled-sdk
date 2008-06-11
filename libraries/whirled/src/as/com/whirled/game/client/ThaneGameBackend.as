//
// $Id$

package com.whirled.game.client {

import com.threerings.presents.util.PresentsContext;
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
    }

    public function getConnectListener () :Function
    {
        return handleUserCodeConnect;
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

    protected var _ctrl :ThaneGameController;
}
}
