//
// $Id$

package com.whirled.game.server;

import java.util.prefs.Preferences;

import com.samskivert.io.PersistenceException;
import com.samskivert.jdbc.RepositoryListenerUnit;
import com.samskivert.util.Invoker;
import com.samskivert.util.ResultListener;

import com.threerings.crowd.data.BodyObject;
import com.threerings.crowd.server.CrowdServer;

import com.whirled.game.server.persist.GameCookieRepository;

import static com.whirled.game.server.Log.log;

/**
 * Manages access to game cookies.
 */
public class GameCookieManager
{
    /**
     * Creates a game cookie manager that stores cookies in Java preferences on the local machine.
     * This should only be used for developer testing.
     */
    public GameCookieManager ()
    {
        _prefs = Preferences.userRoot().node("gameCookieManager");
    }

    /**
     * Creates a game cookie manager that stores cookies in the supplied repository.
     */
    public GameCookieManager (GameCookieRepository repo)
    {
        _repo = repo;
    }

    /**
     * Get the specified user's cookie.
     */
    public void getCookie (final int gameId, final int userId, ResultListener<byte[]> rl)
    {
        if (userId == 0) {
            rl.requestCompleted(null);
            return;
        }

        // use our local prefs if our repository is not initialized
        if (_repo == null) {
            rl.requestCompleted(_prefs.getByteArray(gameId + ":" + userId, (byte[])null));
            return;
        }

        CrowdServer.invoker.postUnit(new RepositoryListenerUnit<byte[]>("getGameCookie", rl) {
            public byte[] invokePersistResult () throws PersistenceException {
                return _repo.getCookie(gameId, userId);
            }
        });
    }

    /**
     * Set the specified user's cookie.
     */
    public void setCookie (final int gameId, final int userId, final byte[] cookie)
    {
        if (userId == 0) {
            // fail to save, silently
            return;
        }

        // use our local prefs if our repository is not initialized
        if (_repo == null) {
            _prefs.putByteArray(gameId + ":" + userId, cookie);
            return;
        }

        CrowdServer.invoker.postUnit(new Invoker.Unit("setGameCookie") {
            public boolean invoke () {
                try {
                    _repo.setCookie(gameId, userId, cookie);
                } catch (PersistenceException pe) {
                    log.warning("Unable to save game cookie [pe=" + pe + "].");
                }
                return false;
            }
        });
    }

    /** Our database repository, which is used in real operation. */
    protected GameCookieRepository _repo;

    /** Our local store, which is used when testing. */
    protected Preferences _prefs;
}
