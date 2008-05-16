//
// $Id$

package com.whirled.game.data {

import com.threerings.crowd.client.PlaceController;
import com.whirled.game.client.FlashWhirledGameController;

/**
 * A game config for a simple multiplayer flash whirled game.
 */
public class FlashWhirledGameConfig extends WhirledGameConfig
{
    public function FlashWhirledGameConfig (
        gameId :int = 0, gameDef :GameDefinition = null)
    {
        super(gameId, gameDef);
    }

    /** @inheritDocs */
    // from WhirledGameConfig
    override protected function createDefaultController () :PlaceController
    {
        return new FlashWhirledGameController();
    }
}
}
