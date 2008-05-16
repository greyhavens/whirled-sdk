//
// $Id$

package com.whirled.game.data {

import com.threerings.crowd.client.PlaceController;
import com.whirled.game.client.ThaneWhirledGameController;

/**
 * A game config for a simple multiplayer thane whirled game.
 */
public class ThaneWhirledGameConfig extends WhirledGameConfig
{
    public function ThaneWhirledGameConfig (
        gameId :int = 0, gameDef :GameDefinition = null)
    {
        super(gameId, gameDef);
    }

    /** @inheritDocs */
    // from WhirledGameConfig
    override protected function createDefaultController () :PlaceController
    {
        return new ThaneWhirledGameController();
    }
}
}
