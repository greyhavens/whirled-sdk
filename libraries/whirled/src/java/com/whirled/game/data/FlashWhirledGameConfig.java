//
// $Id$

package com.whirled.game.data;

/**
 * A game config for a simple multiplayer game, supplied to flash clients.
 */
public class FlashWhirledGameConfig extends WhirledGameConfig
{
    /** A zero argument constructor used when unserializing. */
    public FlashWhirledGameConfig ()
    {
    }

    /** Constructs a game config based on the supplied game definition. */
    public FlashWhirledGameConfig (int gameId, GameDefinition gameDef)
    {
        super(gameId, gameDef);
    }
}
