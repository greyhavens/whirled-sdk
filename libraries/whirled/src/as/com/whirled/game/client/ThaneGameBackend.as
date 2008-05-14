//
// $Id$

package com.whirled.game.client {

import com.threerings.crowd.util.CrowdContext;
import com.whirled.game.data.WhirledGameObject;


/**
 * Manages the backend of the game on a thane client.
 */
public class ThaneGameBackend extends BaseGameBackend
{
    public function ThaneGameBackend (
        ctx :CrowdContext, gameObj :WhirledGameObject, ctrl :WhirledGameController)
    {
        super(ctx, gameObj, ctrl);
    }
}
}
