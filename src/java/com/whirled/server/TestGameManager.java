//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.server;

import com.samskivert.util.ArrayIntSet;

import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationException;

import com.threerings.crowd.data.PlaceObject;
import com.threerings.crowd.server.CrowdServer;

import com.threerings.ezgame.server.EZGameManager;

import com.whirled.client.WhirledGameService;
import com.whirled.data.TestGameObject;
import com.whirled.data.WhirledGameMarshaller;

/**
 * Handles test game services.
 */
public class TestGameManager extends EZGameManager
    implements WhirledGameProvider
{
    // from interface WhirledGameProvider
    public void endGameWithScores (ClientObject caller, int[] playerIds, int[] scores,
                                   int payoutType, WhirledGameService.InvocationListener listener)
        throws InvocationException
    {
        if (!_gameObj.isInPlay()) {
            throw new InvocationException("e.already_ended");
        }
        validateStateModification(caller, false);

        // TODO: award flow fakily?

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
        _winnerIds = winners.toIntArray();
        endGame();
    }

    // from interface WhirledGameProvider
    public void endGameWithWinners (ClientObject caller, int[] winnerIds, int[] loserIds,
                                    int payoutType, WhirledGameService.InvocationListener listener)
        throws InvocationException
    {
        if (!_gameObj.isInPlay()) {
            throw new InvocationException("e.already_ended");
        }
        validateStateModification(caller, false);

        // TODO: award flow fakily?

        // TODO: validate winner ids and loser ids
        _winnerIds = winnerIds;
        endGame();
    }

    @Override // from PlaceManager
    protected PlaceObject createPlaceObject ()
    {
        return new TestGameObject();
    }

    @Override
    protected void didStartup ()
    {
        super.didStartup();

        TestGameObject tobj = (TestGameObject)_plobj;
        tobj.setWhirledGameService((WhirledGameMarshaller)CrowdServer.invmgr.registerDispatcher(
                                       new WhirledGameDispatcher(this)));
    }
}
