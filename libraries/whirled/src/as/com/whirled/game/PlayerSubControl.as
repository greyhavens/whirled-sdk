//
// $Id$

package com.whirled.game {

/**
 * Dispatched when this player has been awarded flow.
 * 
 * @eventType com.whirled.game.FlowAwardedEvent.FLOW_AWARDED
 */
[Event(name="FlowAwarded", type="com.whirled.game.FlowAwardedEvent")]

/**
 * Provides access to 'player' game services. Do not instantiate this class directly,
 * instead access it via GameControl.player.
 */
public class PlayerSubControl extends AbstractSubControl
{
    /**
     * @private Constructed via GameControl
     */
    public function PlayerSubControl (parent :GameControl)
    {
        super(parent);
    }

    /**
     * Get the user-specific game data for the specified user. The first time this is requested per
     * game instance it will be retrieved from the database. After that, it will be returned from
     * memory. 
     */
    public function getUserCookie (occupantId :int, callback :Function) :void
    {
        callHostCode("getUserCookie_v2", occupantId, callback);
    }
    
    /**
     * Store persistent data that can later be retrieved by an instance of this game. The maximum
     * size of this data is 4096 bytes AFTER AMF3 encoding.  Note: there is no playerId parameter
     * because a cookie may only be stored for the current player.
     *
     * @return false if the cookie could not be encoded to 4096 bytes or less; true if the cookie
     * is going to try to be saved. There is no guarantee it will be saved and no way to find out
     * if it failed, but if it fails it will be because the shit hit the fan so hard that there's
     * nothing you can do anyway.
     */
    public function setUserCookie (cookie :Object) :Boolean
    {
        return Boolean(callHostCode("setUserCookie_v1", cookie));
    }

    /**
     * Returns all item packs owned by this client's player.
     */
    public function getPlayerItemPacks () :Array
    {
        return (callHostCode("getPlayerItemPacks_v1") as Array);
    }

    /**
     * Returns true if this client's player has the trophy with the specified identifier.
     */
    public function holdsTrophy (ident :String) :Boolean
    {
        return (callHostCode("holdsTrophy_v1", ident) as Boolean);
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
        return (callHostCode("awardTrophy_v1", ident) as Boolean);
    }

    /**
     * Awards the specified prize item to this client's player. If the supplied prize identifier is
     * not valid, this will not be known until the request is processed on the server, so the
     * method will return successfully but no prize will have been awarded. Thus you should be
     * careful not to misspell your prize identifier in your code or in the associated prize item.
     *
     * <p> Note: a game is only allowed to award a prize once per game session. This is to guard
     * against bugs that might try to award many hundreds of the same prize to a user while playing
     * a game. If you *really* want to award multiple instances of a prize, you will need to make
     * different prize items with unique identifiers which all reference the same target item. </p>
     *
     * <p> Note also: because a game *can* award the same prize more than once if the player earns
     * the prize in separate game sessions, a game that wishes to only award a prize once should
     * couple the award of the prize with the award of a trophy and then structure their code like
     * so: </p>
     *
     * <pre>
     * if (_ctrl.awardTrophy("special_award_trophy")) {
     *     _ctrl.awardPrize("special_award_avatar");
     * }
     * </pre>
     *
     * <p> The first time the player accomplishes the necessary goal, they will be awarded the
     * trophy and the prize. Subsequently, awardTrophy() will return false indicating that the
     * player already has the trophy in question and the prize will not be awarded. Alternatively
     * the game could store whether or not the player has earned the prize in a user cookie. </p>
     */
    public function awardPrize (ident :String) :void
    {
        callHostCode("awardPrize_v1", ident);
    }

    /**
     * @private
     */
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
