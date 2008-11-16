//
// $Id$

package com.whirled.game.server.persist;

import java.util.Set;

import com.google.inject.Inject;
import com.google.inject.Singleton;

import com.samskivert.depot.DepotRepository;
import com.samskivert.depot.PersistenceContext;
import com.samskivert.depot.PersistentRecord;

/**
 * Provides storage services for user cookies used in games.
 */
@Singleton
public class GameCookieRepository extends DepotRepository
{
    @Inject public GameCookieRepository (PersistenceContext ctx)
    {
        super(ctx);
    }

    /**
     * Get the specified game cookie, or null if none.
     */
    public byte[] getCookie (int gameId, int userId)
    {
        GameCookieRecord record = load(
            GameCookieRecord.class, GameCookieRecord.getKey(gameId, userId));
        return record != null ? record.cookie : null;
    }

    /**
     * Set the specified user's game cookie.
     */
    public void setCookie (int gameId, int userId, byte[] cookie)
    {
        if (cookie != null) {
            store(new GameCookieRecord(gameId, userId, cookie));
        } else {
            delete(GameCookieRecord.class, GameCookieRecord.getKey(gameId, userId));
        }
    }

    @Override // from DepotRepository
    protected void getManagedRecords (Set<Class<? extends PersistentRecord>> classes)
    {
        classes.add(GameCookieRecord.class);
    }
}
