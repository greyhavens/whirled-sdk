//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.client {

import com.threerings.util.Name;

import com.threerings.presents.dobj.MessageEvent;

import com.threerings.crowd.data.OccupantInfo;
import com.threerings.crowd.util.CrowdContext;

import com.threerings.ezgame.client.EZGameController;
import com.threerings.ezgame.client.GameControlBackend;
import com.threerings.ezgame.data.EZGameObject;

import com.whirled.data.GameData;
import com.whirled.data.ItemData;
import com.whirled.data.LevelData;
import com.whirled.data.TrophyData;
import com.whirled.data.WhirledGame;

/**
 * Extends the basic EZGame backend with flow and other whirled services.
 */
public class WhirledGameControlBackend extends GameControlBackend
{
    /** From the WhirledGame.java; but we can't define constants in WhirledGame.as. */
    public static const FLOW_AWARDED_MESSAGE :String = "FlowAwarded";

    public function WhirledGameControlBackend (
        ctx :CrowdContext, ezObj :EZGameObject, ctrl :EZGameController)
    {
        super(ctx, ezObj, ctrl);
    }

    public function forceClassInclusion () :void
    {
        var c :Class;
        c = GameData;
        c = LevelData;
        c = ItemData;
        c = TrophyData;
    }

    // from GameControlBackend
    override protected function messageReceivedOnUserObject (event :MessageEvent) :void
    {
        super.messageReceivedOnUserObject(event);

        var name :String = event.getName();
        if (FLOW_AWARDED_MESSAGE == name) {
            var amount :int = int(event.getArgs()[0]);
            var percentile :int = int(event.getArgs()[1]);
            callUserCode("flowAwarded_v1", amount, percentile);
        }
    }

    override protected function populateProperties (o :Object) :void
    {
        super.populateProperties(o);

        o["endGameWithWinners_v1"] = endGameWithWinners_v1;
        o["endGameWithScores_v1"] = endGameWithScores_v1;

        o["getLevelPacks_v1"] = getLevelPacks_v1;
        o["getItemPacks_v1"] = getItemPacks_v1;
        o["getPlayerItemPacks_v1"] = getPlayerItemPacks_v1;
        o["playerHoldsTrophy_v1"] = playerHoldsTrophy_v1;
        o["awardTrophy_v1"] = awardTrophy_v1;
    }

    protected function endGameWithWinners_v1 (
        winnerIds :Array, loserIds :Array, payoutType :int) :void
    {
        validateConnected();

        // pass the buck straight on through, the server will validate everything
        (_ezObj as WhirledGame).getWhirledGameService().endGameWithWinners(
            _ctx.getClient(), toTypedIntArray(winnerIds), toTypedIntArray(loserIds), payoutType,
            createLoggingConfirmListener("endGameWithWinners"));
    }

    protected function endGameWithScores_v1 (playerIds :Array, scores :Array, payoutType :int) :void
    {
        validateConnected();

        // pass the buck straight on through, the server will validate everything
        (_ezObj as WhirledGame).getWhirledGameService().endGameWithScores(
            _ctx.getClient(), toTypedIntArray(playerIds), toTypedIntArray(scores), payoutType,
            createLoggingConfirmListener("endGameWithWinners"));
    }

    protected function getLevelPacks_v1 () :Array
    {
        var packs :Array = [];
        for each (var data :GameData in (_ezObj as WhirledGame).getGameData()) {
            if (data.getType() != GameData.LEVEL_DATA) {
                continue;
            }
            // if the level pack is premium, only add it if every occupant owns it
            if ((data as LevelData).premium) {
                var nonHolder :Boolean = false;
                for each (var playerId :int in getPlayers_v1()) {
                    if (!playerOwnsData(data.getType(), data.ident, playerId)) {
                        nonHolder = true;
                        break;
                    }
                }
                // we'd do this with a labeled continue but that seems to be unreliable in
                // actionscript, awesome!
                if (nonHolder) {
                    continue;
                }
            }
            packs.unshift({ ident: data.ident,
                            name: data.name,
                            mediaURL: data.mediaURL,
                            premium: (data as LevelData).premium });
        }
        return packs;
    }

    protected function getItemPacks_v1 () :Array
    {
        var packs :Array = [];
        for each (var data :GameData in (_ezObj as WhirledGame).getGameData()) {
            if (data.getType() != GameData.ITEM_DATA) {
                continue;
            }
            packs.unshift({ ident: data.ident,
                            name: data.name,
                            mediaURL: data.mediaURL });
        }
        return packs;
    }

    protected function getPlayerItemPacks_v1 () :Array
    {
        return getItemPacks_v1().filter(function (data :GameData, idx :int, array :Array) :Boolean {
            return playerOwnsData(data.getType(), data.ident);
        });
    }

    protected function playerHoldsTrophy_v1 (ident :String) :Boolean
    {
        return playerOwnsData(GameData.TROPHY_DATA, ident);
    }

    protected function awardTrophy_v1 (ident :String) :Boolean
    {
        if (playerOwnsData(GameData.TROPHY_DATA, ident)) {
            return false;
        }
        (_ezObj as WhirledGame).getWhirledGameService().awardTrophy(
            _ctx.getClient(), ident, createLoggingConfirmListener("awardTrophy"));
        return true;
    }

    protected function playerOwnsData (type :int, ident :String) :Boolean
    {
        return false; // this information is provided by the containing system
    }

    override protected function endGame_v2 (... winnerIds) :void
    {
        validateConnected();

        // if this is a table game, all the non-winners are losers, if it's not a table game then
        // no one is a loser because we're not going to declare that all watchers automatically be
        // considered as players and thus contribute to the winners' booty
        var loserIds :Array = [];
        // party games have a zero length players array
        for (var ii :int = 0; ii < _ezObj.players.length; ii++) {
            var occInfo :OccupantInfo = _ezObj.getOccupantInfo(_ezObj.players[ii] as Name);
            if (occInfo != null) {
                loserIds.push(occInfo.bodyOid);
            }
        }
        endGameWithWinners_v1(winnerIds, loserIds, 0) // WhirledGameControl.CASCADING_PAYOUT
    }
}
}
