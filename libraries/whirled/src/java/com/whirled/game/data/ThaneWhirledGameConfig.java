//
// $Id$

package com.whirled.game.data;

/**
 * A game config for a simple multiplayer game, supplied to thane clients.
 */
public class ThaneWhirledGameConfig extends WhirledGameConfig
{
    /** A zero argument constructor used when unserializing. */
    public ThaneWhirledGameConfig ()
    {
    }

    /** Constructs a game config based on the supplied game definition. */
    public ThaneWhirledGameConfig (int gameId, GameDefinition gameDef)
    {
        super(gameId, gameDef);
    }
}
