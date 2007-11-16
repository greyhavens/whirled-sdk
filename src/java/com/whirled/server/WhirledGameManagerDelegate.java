//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.server;

import java.util.ArrayList;

import com.samskivert.util.ArrayIntSet;

import com.threerings.presents.data.ClientObject;
import com.threerings.presents.dobj.DSet;
import com.threerings.presents.server.InvocationException;

import com.threerings.crowd.data.PlaceObject;
import com.threerings.crowd.server.CrowdServer;
import com.threerings.crowd.server.PlaceManager;

import com.threerings.parlor.game.server.GameManagerDelegate;

import com.threerings.ezgame.data.EZGameConfig;
import com.threerings.ezgame.data.GameDefinition;
import com.threerings.ezgame.data.Parameter;
import com.threerings.ezgame.server.EZGameManager;

import com.whirled.client.WhirledGameService;
import com.whirled.data.ContentPackParameter;
import com.whirled.data.GameData;
import com.whirled.data.WhirledGame;
import com.whirled.data.WhirledGameDefinition;
import com.whirled.data.WhirledGameMarshaller;

import static com.whirled.Log.log;

/**
 * Handles implementing the {@link WhirledGameProvider} for test games.
 */
public class WhirledGameManagerDelegate extends GameManagerDelegate
    implements WhirledGameProvider
{
    @Override // from PlaceManagerDelegate
    public void setPlaceManager (PlaceManager plmgr)
    {
        super.setPlaceManager(plmgr);
        _gmgr = (EZGameManager)plmgr;
    }

    // from interface WhirledGameProvider
    public void awardTrophy (ClientObject caller, String ident,
                             WhirledGameService.InvocationListener listener)
        throws InvocationException
    {
        // TODO: add the awarded trophy to something the client can see so that holdsTrophy() can
        // return the correct value
        _gmgr.systemMessage(null, "Trophy awarded: " + ident);
    }

    // from interface WhirledGameProvider
    public void awardPrize (ClientObject caller, String ident,
                            WhirledGameService.InvocationListener listener)
        throws InvocationException
    {
        _gmgr.systemMessage(null, "Prize awarded: " + ident);
    }

    // from interface WhirledGameProvider
    public void endGameWithScores (ClientObject caller, int[] playerIds, int[] scores,
                                   int payoutType, WhirledGameService.InvocationListener listener)
        throws InvocationException
    {
        _gmgr.validateCanEndGame(caller);

        // TODO: award based on relative scores?
        awardFakeFlow(playerIds);

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
        _gmgr.endGame(caller, winners.toIntArray(), listener);
    }

    // from interface WhirledGameProvider
    public void endGameWithWinners (ClientObject caller, int[] winnerIds, int[] loserIds,
                                    int payoutType, WhirledGameService.InvocationListener listener)
        throws InvocationException
    {
        _gmgr.validateCanEndGame(caller);
        awardFakeFlow(winnerIds);
        _gmgr.endGame(caller, winnerIds, listener);
    }

    @Override
    public void didStartup (PlaceObject plobj)
    {
        super.didStartup(plobj);
        
        WhirledGame game = (WhirledGame)plobj;
        game.setWhirledGameService((WhirledGameMarshaller)CrowdServer.invmgr.registerDispatcher(
                                       new WhirledGameDispatcher(this)));

        EZGameConfig config = (EZGameConfig)_gmgr.getGameConfig();
        WhirledGameDefinition gamedef = (WhirledGameDefinition) config.getGameDefinition();
        
        ArrayList<GameData> data = new ArrayList<GameData>();
        if (gamedef.packs != null) {
            for (Parameter pack : gamedef.packs) {
                if (pack instanceof ContentPackParameter) {
                    data.add(((ContentPackParameter)pack).toGameData());
                }
            }   
        }
        game.setGameData(data.toArray(new GameData[0]));
    }

    /**
     * Award some fake flow, so that game creators can test the FlowAwardedEvent.
     */
    protected void awardFakeFlow (int[] playerOids)
    {
        for (int playerOid : playerOids) {
            ClientObject cliObj = (ClientObject) CrowdServer.omgr.getObject(playerOid);
            if (cliObj != null) {
                cliObj.postMessage(WhirledGame.FLOW_AWARDED_MESSAGE, 10 /*flow*/, 49 /*percentile*/);
            }
        }
    }

    protected EZGameManager _gmgr;
}
