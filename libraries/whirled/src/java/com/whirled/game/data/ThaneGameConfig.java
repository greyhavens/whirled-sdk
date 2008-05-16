//
// $Id$

package com.whirled.game.data;

/**
 * A game config for a simple multiplayer game, supplied to thane clients.
 */
public class ThaneGameConfig extends BaseGameConfig
{
    /** A zero argument constructor used when unserializing. */
    public ThaneGameConfig ()
    {
    }

    /** Constructs a game config based on the supplied game definition. */
    public ThaneGameConfig (int gameId, GameDefinition gameDef)
    {
        super(gameId, gameDef);
    }
}
