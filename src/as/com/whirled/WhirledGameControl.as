//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled {

import flash.display.DisplayObject;
import flash.geom.Rectangle;

import com.threerings.ezgame.EZGameControl;

/**
 * Dispatched when this player has been awarded flow.
 * 
 * @eventType com.whirled.FlowAwardedEvent.FLOW_AWARDED
 */
[Event(name="flowAwarded", type="com.whirled.FlowAwardedEvent")]

/**
 * Adds whirled-specific controls to EZGameControl
 */
public class WhirledGameControl extends EZGameControl
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

    /**
     * Creates a control and connects to the Whirled game system.
     *
     * @param disp the display object that is the game's UI.
     * @param autoReady if true, the game will automatically be started when initialization is
     * complete, if false, the game will not start until all clients call playerReady().
     *
     * @see com.threerings.ezgame.EZGameControl#playerReady()
     */
    public function WhirledGameControl (disp :DisplayObject, autoReady :Boolean = true)
    {
        super(disp, autoReady);
    }

    /**
     * Return the headshot image for the given occupant in the form of a Sprite object.
     *
     * The sprite are cached in the client backend so the user should not worry too much
     * about multiple requests for the same occupant.
     *
     * @param callback signature: function (sprite :Sprite, success :Boolean) :void
     */
    public function getHeadShot (occupant :int, callback :Function) :void
    {
        callEZCode("getHeadShot_v1", occupant, callback);
    }

    /**
     * Returns the bounds of the "stage" on which the game will be drawn. This is mainly useful for
     * the width and height so that the game can know how much area it has to cover, however the x
     * and y coordinates will also indicate the offset from the upper left of the stage of the view
     * rectangle that contains the game.
     *
     * TODO: the chat channel panel can be opened and closed during a game, so we need to dispatch
     * an event to let the game know in case it wants to do something special to handle that.
     */
    public function getStageBounds () :Rectangle
    {
        return Rectangle(callEZCode("getStageBounds_v1"));
    }

    /**
     * Set a label to be shown above the occupants list in the game.
     * Set to null to remove the label.
     */
    public function setOccupantsLabel (label :String) :void
    {
        callEZCode("setOccupantsLabel_v1", label);
    }

    /**
     * Clear all the scores displayed in the occupants list.
     *
     * @param sortValuesToo if true, also clear the sort values, returning the list
     * to the default sort order.
     */
    public function clearScores (sortValuesToo :Boolean = false) :void
    {
        callEZCode("clearScores_v1", sortValuesToo);
    }

    /**
     * Set scores for seated players.
     *
     * @param scores an array of 'score' values that must correspond to the seated players.
     * The scores may be numeric or String and will be displayed after the player names.
     * @param sortValues an array of sorting values that must correpond to the seated players.
     * If not specified then the scoreValues are used to sort the occupants list.
     */
    public function setPlayerScores (scores :Array, sortValues :Array = null) :void
    {
        callEZCode("setPlayerScores_v1", scores, sortValues);
    }

    /**
     * Set score or sortValue values for occupants. You may want to call clearScores prior
     * to using this method to ensure that occupants that you don't specify are cleared out.
     *
     * @param scores an Object mapping occupantId to a score value (which may be a String or
     * numeric), or to a two-dimensional array containing the score value and the sortValue.
     */
    public function setMappedScores (scores :Object) :void
    {
        callEZCode("setMappeScores_v1", scores);
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
        return (callEZCode("getLevelPacks_v1") as Array);
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
        return (callEZCode("getItemPacks_v1") as Array);
    }

    /**
     * Returns all item packs owned by this client's player.
     */
    public function getPlayerItemPacks () :Array
    {
        return (callEZCode("getPlayerItemPacks_v1") as Array);
    }

    /**
     * Returns true if this client's player has the trophy with the specified identifier.
     */
    public function holdsTrophy (ident :String) :Boolean
    {
        return (callEZCode("holdsTrophy_v1", ident) as Boolean);
    }

    /**
     * Awards the specified trophy to this client's player. If the supplied trophy identifier is
     * not valid, this will not be known until the request is processed on the server, so the
     * method will return succcessfully but no trophy will have been awarded. Thus, you should be
     * careful not to misspell your trophy identifier in your code or in the associated trophy
     * source item.
     *
     * @return true if the trophy was awarded, false if the player already has that trophy.
     */
    public function awardTrophy (ident :String) :Boolean
    {
        return (callEZCode("awardTrophy_v1", ident) as Boolean);
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
     * the winners.
     *
     * <p> If flow is awarded, a FLOW_AWARDED event will be dispatched <em>before</em> the
     * GAME_ENDED event is dispatched informing the client that the game has ended.
     *
     * <p> Players' ratings will also be updated using the Elo algorigthm wherein each player is
     * rated against the average ratings of the players that the defeated or were defeated by.  In
     * a two player game this degenerates into the standard Elo algorithm.
     *
     * @see http://en.wikipedia.org/wiki/ELO_rating_system
     */
    public function endGameWithWinners (winnerIds :Array, loserIds :Array, payoutType :int) :void
    {
        callEZCode("endGameWithWinners_v1", winnerIds, loserIds, payoutType);
    }

    /**
     * Ends the game, reporting the scores earned by each player in the game, awarding flow
     * according to the specified strategy and updating player ratings.
     *
     * <p> Flow is awarded based on the supplied payout type, either CASCADING_PAYOUT,
     * WINNERS_TAKE_ALL or TO_EACH_THEIR_OWN. In the case of WINNERS_TAKE_CALL, the highest scoring
     * player or players will be considered the winner(s) and in the case of CASCADING_PAYOUT,
     * players will be ranked according to their scores, higher scores being considered better.
     *
     * <p> If flow is awarded, a FLOW_AWARDED event will be dispatched <em>before</em> the
     * GAME_ENDED event is dispatched informing the client that the game has ended.
     *
     * <p> Both rating and a player's flow payout will be adjusted based on their score. Whirled
     * will track every score reported by your game for its entire existence and will convert newly
     * reported scores to a percentile value between 0 and 99 (inclusive) indicating the percentage
     * of scores in the entire score history that are below the reported score. That percentile
     * ranking will be used to adjust the players rating as well as to determine their individual
     * flow payout.
     *
     * <p> Note that scores must be integers >= 0 and higher scores are considered better, so if
     * your game naturally operates with scores where lower is better (elapsed time in a racing
     * game, for example), then you must convert your score to a positive integer by, for example,
     * subtracting your score from a hypothentical worse possible score. For example:
     *
     * <p><code>score = Math.max(WORST_POSSIBLE_TIME - actualTime, 0)</code>
     */
    public function endGameWithScores (playerIds :Array, scores :Array /* of int */,
        payoutType :int) :void
    {
        callEZCode("endGameWithScores_v1", playerIds, scores, payoutType);
    }

    /**
     * A convenience function for ending a single player game with the supplied score. This is
     * equivalent to: <code>endGameWithScores([ getMyId() ], [ score ], TO_EACH_THEIR_OWN)</code>.
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

    /**
     * Instructs the game client to return to Whirled.
     */
    public function backToWhirled (showLobby :Boolean = false) :void
    {
        callEZCode("backToWhirled_v1", showLobby);
    }

    // from EZGameControl
    override protected function populateProperties (o :Object) :void
    {
        super.populateProperties(o);
        o["flowAwarded_v1"] = flowAwarded_v1;
    }

    /**
     * Private method to post a FlowAwardedEvent.
     */
    private function flowAwarded_v1 (amount :int, percentile :int) :void
    {
        dispatch(new FlowAwardedEvent(amount, percentile));
    }
}
}
