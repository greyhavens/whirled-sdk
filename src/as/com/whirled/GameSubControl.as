//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled {

import com.threerings.util.Log;

import com.threerings.ezgame.EZGameSubControl;

/**
 * Provides access to the 'game' game services. Do not instantiate this class yourself,
 * access it via GameControl.game.
 */
public class GameSubControl extends EZGameSubControl
{
    /** Cascading payout skews awards toward the winners by giving 50% of last place's payout to
     * first place, 25% to the next inner pair of opponents (third to second in a four player game,
     * for example), and so on. */
    public static const CASCADING_PAYOUT :int = 0;

    /** Winner takes all splits the total flow available to award to all players in the game among
     * those identified as winners at the end of the game. */
    public static const WINNERS_TAKE_ALL :int = 1;
    
    /** Each player receives a payout based only on their performance during the game and not
     * influenced by their relative ranking to one another. */
    public static const TO_EACH_THEIR_OWN :int = 2;

    public function GameSubControl (parent :WhirledGameControl)
    {
        super(parent);
    }

    /**
     * Returns the set of level packs available to this game as an array of objects with the
     * following properties:
     *
     * <pre>
     * ident - string identifier of level pack
     * name - human readable name of level pack
     * mediaURL - URL for level pack content
     * premium - boolean indicating that content is premium or not
     * </pre>
     *
     * This will contain all free level packs that are registered for this game as well as the
     * premium level packs owned by this client's player.
     */
    public function getLevelPacks () :Array
    {
        return (callHostCode("getLevelPacks_v1") as Array);
    }

    /**
     * Returns the set of all item packs available to this game as an array of objects with the
     * following properties:
     *
     * <pre>
     * ident - string identifier of item pack
     * name - human readable name of item pack
     * mediaURL - URL for item pack content
     * </pre>
     */
    public function getItemPacks () :Array
    {
        return (callHostCode("getItemPacks_v1") as Array);
    }

    /**
     * Ends the game, declaring which players are the winners (if players tie, more than one player
     * can be declared a winner. In addition to ending the game, this method awards flow and
     * updates players ratings.
     *
     * <p> Flow is awarded based on the supplied payout type, either CASCADING_PAYOUT or
     * WINNERS_TAKE_ALL. In the case of WINNERS_TAKE_ALL, the losers will have all of their
     * individual flow payouts combined into a pool and that pool will be evenly divided among the
     * winners and added to their respective individual flow payouts. In the case of
     * CASCADING_PAYOUT, the losers will only have 50% of their individual flow payouts given to
     * the winners. </p>
     *
     * <p> If flow is awarded, a FLOW_AWARDED event will be dispatched <em>before</em> the
     * GAME_ENDED event is dispatched informing the client that the game has ended. </p>
     *
     * <p> Players' ratings will also be updated using the Elo algorigthm wherein each player is
     * rated against the average ratings of the players that the defeated or were defeated by.  In
     * a two player game this degenerates into the standard Elo algorithm. </p>
     *
     * @see http://en.wikipedia.org/wiki/ELO_rating_system
     */
    public function endGameWithWinners (winnerIds :Array, loserIds :Array, payoutType :int) :void
    {
        callHostCode("endGameWithWinners_v1", winnerIds, loserIds, payoutType);
    }

    /**
     * Ends the game, reporting the scores earned by each player in the game, awarding flow
     * according to the specified strategy and updating player ratings.
     *
     * <p> Flow is awarded based on the supplied payout type, either CASCADING_PAYOUT,
     * WINNERS_TAKE_ALL or TO_EACH_THEIR_OWN. In the case of WINNERS_TAKE_CALL, the highest scoring
     * player or players will be considered the winner(s) and in the case of CASCADING_PAYOUT,
     * players will be ranked according to their scores, higher scores being considered better. </p>
     *
     * <p> If flow is awarded, a FLOW_AWARDED event will be dispatched <em>before</em> the
     * GAME_ENDED event is dispatched informing the client that the game has ended. </p>
     *
     * <p> Both rating and a player's flow payout will be adjusted based on their score. Whirled
     * will track every score reported by your game for its entire existence and will convert newly
     * reported scores to a percentile value between 0 and 99 (inclusive) indicating the percentage
     * of scores in the entire score history that are below the reported score. That percentile
     * ranking will be used to adjust the players rating as well as to determine their individual
     * flow payout. </p>
     *
     * <p> Note that scores must be integers >= 0 and higher scores are considered better, so if
     * your game naturally operates with scores where lower is better (elapsed time in a racing
     * game, for example), then you must convert your score to a positive integer by, for example,
     * subtracting your score from a hypothentical worse possible score. For example: </p>
     *
     * <p><code>score = Math.max(WORST_POSSIBLE_TIME - actualTime, 1)</code>
     *
     * <p> Note that if a game is ended with all players scores equal of zero, it will be assumed
     * that the players in question abandoned the game and no flow will be paid out, nor will their
     * ratings be updated. </p>
     */
    public function endGameWithScores (playerIds :Array, scores :Array /* of int */,
        payoutType :int) :void
    {
        callHostCode("endGameWithScores_v1", playerIds, scores, payoutType);
    }
    /**
     * A convenience function for ending a single player game with the supplied score. This is
     * equivalent to: <code>endGameWithScores([ getMyId() ], [ score ], TO_EACH_THEIR_OWN)</code>.
     *
     * <p> Note that if a single player game is ended with a score of zero, it will be assumed that
     * the player in question abandoned the game and no flow will be paid out, nor will their
     * rating be updated. </p>
     */
    public function endGameWithScore (score :int) :void
    {
        endGameWithScores([ getMyId() ], [ score ], TO_EACH_THEIR_OWN);
    }

    /**
     * Don't use this method. Use endGameWithWinners() or endGameWithScores().
     */
    override public function endGame (winnerIds :Array) :void
    {
        Log.getLog(this).warning("Don't use endGame(winnerIds) use " +
                                 "WhirledGameControl.endGameWithWinners() or " +
                                 "WhirledGameControl.endGameWithScores().");
        super.endGame(winnerIds); // we'll turn this into endGameWithWinners() on the backend
    }
}
}
