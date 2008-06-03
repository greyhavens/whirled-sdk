//
// $Id$

package com.whirled.game.client {

import com.threerings.crowd.util.CrowdContext;
import com.whirled.game.data.WhirledGameObject;
import com.whirled.game.data.BaseGameConfig;


/**
 * Manages the backend of the game on a thane client.
 */
public class ThaneGameBackend extends BaseGameBackend
{
    public function ThaneGameBackend (
        ctx :CrowdContext, gameObj :WhirledGameObject, ctrl :ThaneGameController)
    {
        super(ctx, gameObj);
        _ctrl = ctrl;
    }

    override protected function getConfig () :BaseGameConfig
    {
        return _ctrl.getPlaceConfig() as BaseGameConfig;
    }

    protected var _ctrl :ThaneGameController;
}
}
