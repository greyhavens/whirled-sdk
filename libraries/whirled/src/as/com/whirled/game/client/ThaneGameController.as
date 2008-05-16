//
// $Id$

package com.whirled.game.client {

/**
 * A controller for thane whirled games.
 */
public class ThaneGameController extends BaseGameController
{
    /** @inheritDocs */
    // from BaseGameController
    protected override function createBackend () :BaseGameBackend
    {
        return new ThaneGameBackend(_ctx, _gameObj, this);
    }

}
}
