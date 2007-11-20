//
// $Id$

package com.whirled.client {

import com.threerings.ezgame.client.EZGameController;

public class WhirledGameController extends EZGameController
{
    /**
     * Request to leave the game.
     */
    public function backToWhirled (showLobby :Boolean = false) :void
    {
        throw new Error("abstract");
    }

    override protected function gameDidStart () :void
    {
        super.gameDidStart();

        (_view as WhirledGamePanel).checkRematchVisibility();
    }

    override protected function gameDidEnd () :void
    {
        super.gameDidEnd();

        (_view as WhirledGamePanel).checkRematchVisibility();
    }
}
}
