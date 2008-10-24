//
// $Id$

package com.whirled.game.server;

import java.util.ArrayList;

import com.samskivert.util.ArrayIntSet;

import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationException;

import com.threerings.crowd.data.PlaceObject;
import com.threerings.parlor.data.Parameter;

import com.whirled.game.client.WhirledGameService;
import com.whirled.game.data.ContentPackParameter;
import com.whirled.game.data.GameData;
import com.whirled.game.data.GameDefinition;
import com.whirled.game.data.TestGameDefinition;
import com.whirled.game.data.WhirledGameConfig;
import com.whirled.game.data.WhirledGameObject;

import static com.whirled.Log.log;

public class TestGameManager extends WhirledGameManager
{
    // from interface WhirledGameProvider
    public void awardTrophy (ClientObject caller, String ident, int playerId,
                             WhirledGameService.InvocationListener listener)
        throws InvocationException
    {
        // TODO: add the awarded trophy to something the client can see so that holdsTrophy() can
        // return the correct value
        systemMessage(null, "Trophy awarded: " + ident);
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

        // TODO: award based on relative scores?
        awardFakeCoins(playerIds);

        // TODO: validate player ids?
        int highScore = 0;
        ArrayIntSet winners = new ArrayIntSet();
        for (int ii = 0; ii < playerIds.length; ii++) {
            if (scores[ii] > highScore) {
                winners.clear();
                winners.add(playerIds[ii]);
            } else if (scores[ii] == highScore) {
                winners.add(playerIds[ii]);
            }
        }
        endGame(caller, winners.toIntArray(), listener);
    }

    // from interface WhirledGameProvider
    public void endGameWithWinners (ClientObject caller, int[] winnerIds, int[] loserIds, 
                                    int payoutType, WhirledGameService.InvocationListener listener)
        throws InvocationException
    {
        validateCanEndGame(caller);
        awardFakeCoins(winnerIds);
        endGame(caller, winnerIds, listener);
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
    protected void awardFakeCoins (int[] playerOids)
    {
        for (int playerOid : playerOids) {
            ClientObject cliObj = (ClientObject)_omgr.getObject(playerOid);
            if (cliObj != null) {
                cliObj.postMessage(WhirledGameObject.COINS_AWARDED_MESSAGE,
                    10 /*coins*/, 49 /*percentile*/, Boolean.TRUE /*for real?*/);
            }
        }
    }
}
