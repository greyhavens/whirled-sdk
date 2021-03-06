//
// $Id$
//
// Copyright (c) 2007-2011 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.server;

import java.util.ArrayList;
import java.util.prefs.BackingStoreException;
import java.util.prefs.Preferences;

import com.samskivert.util.ArrayIntSet;
import com.samskivert.util.ResultListener;

import com.threerings.presents.data.ClientObject;
import com.threerings.presents.data.InvocationCodes;

import com.threerings.crowd.data.BodyObject;

import com.threerings.presents.server.InvocationException;

import com.threerings.parlor.data.Parameter;

import com.whirled.game.client.WhirledGameService;
import com.whirled.game.data.ContentPackParameter;
import com.whirled.game.data.GameContentOwnership;
import com.whirled.game.data.GameData;
import com.whirled.game.data.TestGameDefinition;
import com.whirled.game.data.WhirledGameConfig;
import com.whirled.game.data.WhirledGameObject;
import com.whirled.game.data.WhirledPlayerObject;

import static com.whirled.Log.log;

public class TestGameManager extends WhirledGameManager
{
    public TestGameManager ()
    {
        _prefs = Preferences.userRoot().node("testGameManager/" + System.getProperty("gameName"));
    }

    // from interface WhirledGameProvider
    public void awardTrophy (ClientObject caller, String ident, int playerId,
                             WhirledGameService.InvocationListener listener)
        throws InvocationException
    {
        // TODO: let games specify their trophies in their config.xml so that we have something
        // to validate their requested trophy awarding against.

        WhirledPlayerObject plobj = (WhirledPlayerObject)checkWritePermission(caller, playerId);
        if (plobj == null) {
            throw new InvocationException(InvocationCodes.ACCESS_DENIED);
        }

        // if the player already has this trophy, ignore the request
        int gameId = _gameconfig.getGameId();
        if (plobj.ownsGameContent(gameId, GameData.TROPHY_DATA, ident)) {
            return;
        }

        // add it to the runtime and announce it to the player.
        plobj.addToGameContent(new GameContentOwnership(gameId, GameData.TROPHY_DATA, ident));
        systemMessage(null, "Trophy awarded: " + ident);

        // persist it in java preferences
        _prefs.putBoolean(playerId + ":" + ident, true);
    }

    // from interface WhirledGameProvider
    public void awardPrize (ClientObject caller, String ident, int playerId,
                            WhirledGameService.InvocationListener listener)
        throws InvocationException
    {
        systemMessage(null, "Prize awarded: " + ident);
    }

    // from interface WhirledGameProvider
    public void endGameWithScores (ClientObject caller, int[] playerIds, int[] scores,
                                   int payoutType, int gameMode,
                                   WhirledGameService.InvocationListener listener)
        throws InvocationException
    {
        validateCanEndGame(caller);
        awardFakeCoins(playerIds);
        endGame();
    }

    // from interface WhirledGameProvider
    public void endGameWithWinners (ClientObject caller, int[] winnerIds, int[] loserIds,
                                    int payoutType, WhirledGameService.InvocationListener listener)
        throws InvocationException
    {
        validateCanEndGame(caller);
        awardFakeCoins(winnerIds);
        endGame();
    }

    // from interface WhirledGameProvider
    public void purchaseItemPack (ClientObject caller, int playerId, String ident,
                                 WhirledGameService.InvocationListener listener)
        throws InvocationException
    {
        // nada
    }

    // from interface WhirledGameProvider
    public void consumeItemPack (ClientObject caller, int playerId, String ident,
                                 WhirledGameService.InvocationListener listener)
        throws InvocationException
    {
        // nada
    }

    @Override
    protected void didStartup ()
    {
        super.didStartup();

        WhirledGameConfig config = (WhirledGameConfig) _gameconfig;
        TestGameDefinition gamedef = (TestGameDefinition) config.getGameDefinition();

        ArrayList<GameData> data = new ArrayList<GameData>();
        if (gamedef.packs != null) {
            for (Parameter pack : gamedef.packs) {
                if (pack instanceof ContentPackParameter) {
                    data.add(((ContentPackParameter)pack).toGameData());
                }
            }
        }
        _gameObj.setGameData(data.toArray(new GameData[0]));
    }

    /**
     * Award some fake coins, so that game creators can test the CoinsAwardedEvent.
     */
    protected void awardFakeCoins (int[] playerIds)
    {
        for (int playerId : playerIds) {
            BodyObject bobj = getOccupantById(playerId);
            if (bobj != null) {
                bobj.postMessage(WhirledGameObject.COINS_AWARDED_MESSAGE,
                    10 /*coins*/, 49 /*percentile*/, Boolean.TRUE /*for real?*/);
            }
        }
    }

    @Override
    protected void resolveContentOwnership (BodyObject body, ResultListener<Void> listener)
    {
        WhirledPlayerObject plobj = (WhirledPlayerObject)body;
        int gameId = _gameconfig.getGameId();
        if (plobj.isContentResolved(gameId)) {
            listener.requestCompleted(null);
            return;
        }

        String pidPrefix = getPlayerPersistentId(plobj) + ":";
        plobj.startTransaction();
        try {
            for (String key : _prefs.keys()) {
                if (key.startsWith(pidPrefix)) {
                    plobj.addToGameContent(new GameContentOwnership(
                        _gameconfig.getGameId(), GameData.TROPHY_DATA,
                        key.substring(pidPrefix.length())));
                }
            }
        } catch (BackingStoreException bse) {
            log.warning("Error attempting to resolve player trophies", bse);
        } finally {
            plobj.addToGameContent(new GameContentOwnership(gameId,
                GameData.RESOLUTION_MARKER, WhirledPlayerObject.RESOLVED));
            plobj.commitTransaction();
        }
        listener.requestCompleted(null);
    }

    protected Preferences _prefs;
}
