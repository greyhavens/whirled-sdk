//
// $Id$

package com.whirled.game.data;

import java.io.IOException;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;

import com.threerings.util.Name;

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.presents.dobj.DSet;

import com.threerings.parlor.game.data.GameObject;
import com.threerings.parlor.turn.data.TurnGameObject;

import com.whirled.game.server.PropertySpaceHelper;

/**
 * Contains the data for a whirled game.
 */
public class WhirledGameObject extends GameObject
    implements TurnGameObject, PropertySpaceObject
{
    /** The identifier for a MessageEvent containing a user message. */
    public static final String USER_MESSAGE = "Umsg";

    /** The identifier for a MessageEvent containing game-system chat. */
    public static final String GAME_CHAT = "Uchat";

    /** The identifier for a MessageEvent containing ticker notifications. */
    public static final String TICKER = "Utick";

    /** A message dispatched to each player's client object when coins are awarded. */
    public static final String COINS_AWARDED_MESSAGE = "CoinsAwarded";

    /** Cascading payout skews awards toward the winners by giving 50% of last place's payout to
     * first place, 25% to the next inner pair of opponents (third to second in a four player game,
     * for example), and so on. It is very similar overall to WINNERS_TAKE_ALL, only it rewards
     * everyone at least a little bit. */
    public static final int CASCADING_PAYOUT = 0;

    /** Winner takes all splits the total coins available to award to all players in the game among
     * those identified as winners at the end of the game. When used with endGameWithScores, it
     * is intended for games where each player's performance is independant of the others and
     * can be measured against a global standard. The winner(s) will get more coins if they beat
     * someone else who played well than if they beat someone who played poorly.
     * Using it with endGameWithWinners() is intended for games in which there is no per-player
     * score, just some player(s) defeating others. In this case, the game is stating that
     * it cannot distinguish between an excellent player and a poor player, just one won
     * over the others.
     */
    public static final int WINNERS_TAKE_ALL = 1;

    /** Each player receives a payout based only on their score and not influenced by the
     * scores of any other player. */
    public static final int TO_EACH_THEIR_OWN = 2;

    /** Proportional is used for games where there is no way to measure player's performance
     * against a global standard, but where the scores are subjective to the particular players
     * currently playing. Each player vies to get their score the highest, and the coins are split
     * up according to the relative scores. */
    public static final int PROPORTIONAL = 3;

    // AUTO-GENERATED: FIELDS START
    /** The field name of the <code>roundId</code> field. */
    public static final String ROUND_ID = "roundId";

    /** The field name of the <code>controllerOid</code> field. */
    public static final String CONTROLLER_OID = "controllerOid";

    /** The field name of the <code>turnHolder</code> field. */
    public static final String TURN_HOLDER = "turnHolder";

    /** The field name of the <code>userCookies</code> field. */
    public static final String USER_COOKIES = "userCookies";

    /** The field name of the <code>gameData</code> field. */
    public static final String GAME_DATA = "gameData";

    /** The field name of the <code>whirledGameService</code> field. */
    public static final String WHIRLED_GAME_SERVICE = "whirledGameService";

    /** The field name of the <code>propertyService</code> field. */
    public static final String PROPERTY_SERVICE = "propertyService";

    /** The field name of the <code>messageService</code> field. */
    public static final String MESSAGE_SERVICE = "messageService";
    // AUTO-GENERATED: FIELDS END

    /** The current round id for this game. Rounds divide a single gameplay session into smaller
     * units. */
    public int roundId;

    /** The client that is in control of this game. The first client to enter will be assigned
     * control and control will subsequently be reassigned if that client disconnects or leaves. */
    public int controllerOid;

    /** The current turn holder. */
    public Name turnHolder;

    /** A set of loaded user cookies. */
    public DSet<UserCookie> userCookies;

    /** The various game data available to this game. */
    public GameData[] gameData;

    /** The service interface for requesting special things from the server. */
    public WhirledGameMarshaller whirledGameService;
    
    /** The service interface for dealing with properties. */
    public PropertySpaceMarshaller propertyService;

    /** The service for sending messages to everyone in the game. */
    public WhirledGameMessageMarshaller messageService;

    // from PropertySpaceObject
    public HashMap<String, Object> getUserProps ()
    {
        return _props;
    }

    // from PropertySpaceObject
    public Set<String> getDirtyProps ()
    {
        return _dirty;
    }

    // from TurnGameObject
    public String getTurnHolderFieldName ()
    {
        return TURN_HOLDER;
    }

    // from TurnGameObject
    public Name getTurnHolder ()
    {
        return turnHolder;
    }

    // from TurnGameObject
    public Name[] getPlayers ()
    {
        return players;
    }

    // AUTO-GENERATED: METHODS START
    /**
     * Requests that the <code>roundId</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    public void setRoundId (int value)
    {
        int ovalue = this.roundId;
        requestAttributeChange(
            ROUND_ID, Integer.valueOf(value), Integer.valueOf(ovalue));
        this.roundId = value;
    }

    /**
     * Requests that the <code>controllerOid</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    public void setControllerOid (int value)
    {
        int ovalue = this.controllerOid;
        requestAttributeChange(
            CONTROLLER_OID, Integer.valueOf(value), Integer.valueOf(ovalue));
        this.controllerOid = value;
    }

    /**
     * Requests that the <code>turnHolder</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    public void setTurnHolder (Name value)
    {
        Name ovalue = this.turnHolder;
        requestAttributeChange(
            TURN_HOLDER, value, ovalue);
        this.turnHolder = value;
    }

    /**
     * Requests that the specified entry be added to the
     * <code>userCookies</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    public void addToUserCookies (UserCookie elem)
    {
        requestEntryAdd(USER_COOKIES, userCookies, elem);
    }

    /**
     * Requests that the entry matching the supplied key be removed from
     * the <code>userCookies</code> set. The set will not change until the
     * event is actually propagated through the system.
     */
    public void removeFromUserCookies (Comparable<?> key)
    {
        requestEntryRemove(USER_COOKIES, userCookies, key);
    }

    /**
     * Requests that the specified entry be updated in the
     * <code>userCookies</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    public void updateUserCookies (UserCookie elem)
    {
        requestEntryUpdate(USER_COOKIES, userCookies, elem);
    }

    /**
     * Requests that the <code>userCookies</code> field be set to the
     * specified value. Generally one only adds, updates and removes
     * entries of a distributed set, but certain situations call for a
     * complete replacement of the set value. The local value will be
     * updated immediately and an event will be propagated through the
     * system to notify all listeners that the attribute did
     * change. Proxied copies of this object (on clients) will apply the
     * value change when they received the attribute changed notification.
     */
    public void setUserCookies (DSet<UserCookie> value)
    {
        requestAttributeChange(USER_COOKIES, value, this.userCookies);
        DSet<UserCookie> clone = (value == null) ? null : value.typedClone();
        this.userCookies = clone;
    }

    /**
     * Requests that the <code>gameData</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    public void setGameData (GameData[] value)
    {
        GameData[] ovalue = this.gameData;
        requestAttributeChange(
            GAME_DATA, value, ovalue);
        this.gameData = (value == null) ? null : value.clone();
    }

    /**
     * Requests that the <code>index</code>th element of
     * <code>gameData</code> field be set to the specified value.
     * The local value will be updated immediately and an event will be
     * propagated through the system to notify all listeners that the
     * attribute did change. Proxied copies of this object (on clients)
     * will apply the value change when they received the attribute
     * changed notification.
     */
    public void setGameDataAt (GameData value, int index)
    {
        GameData ovalue = this.gameData[index];
        requestElementUpdate(
            GAME_DATA, index, value, ovalue);
        this.gameData[index] = value;
    }

    /**
     * Requests that the <code>whirledGameService</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    public void setWhirledGameService (WhirledGameMarshaller value)
    {
        WhirledGameMarshaller ovalue = this.whirledGameService;
        requestAttributeChange(
            WHIRLED_GAME_SERVICE, value, ovalue);
        this.whirledGameService = value;
    }

    /**
     * Requests that the <code>propertyService</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    public void setPropertyService (PropertySpaceMarshaller value)
    {
        PropertySpaceMarshaller ovalue = this.propertyService;
        requestAttributeChange(
            PROPERTY_SERVICE, value, ovalue);
        this.propertyService = value;
    }

    /**
     * Requests that the <code>messageService</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    public void setMessageService (WhirledGameMessageMarshaller value)
    {
        WhirledGameMessageMarshaller ovalue = this.messageService;
        requestAttributeChange(
            MESSAGE_SERVICE, value, ovalue);
        this.messageService = value;
    }
    // AUTO-GENERATED: METHODS END

    /**
     * A custom serialization method.
     */
    public void writeObject (ObjectOutputStream out)
        throws IOException
    {
        out.defaultWriteObject();

        PropertySpaceHelper.writeProperties(this, out);
    }

    /**
     * A custom serialization method.
     */
    public void readObject (ObjectInputStream ins)
        throws IOException, ClassNotFoundException
    {
        ins.defaultReadObject();

        PropertySpaceHelper.readProperties(this, ins);
    }

    /**
     * The current state of game data.
     * On the server, this will be a byte[] for normal properties and a byte[][] for array
     * properties. On the client, the actual values are kept whole.
     */
    protected transient HashMap<String, Object> _props = new HashMap<String, Object>();

    /**
     * The persistent properties that have been written to since startup.
     */
    protected transient Set<String> _dirty = new HashSet<String>();
}
