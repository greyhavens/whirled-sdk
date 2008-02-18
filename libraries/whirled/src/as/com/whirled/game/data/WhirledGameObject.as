//
// $Id$

package com.whirled.game.data {

import flash.events.Event;

import flash.utils.ByteArray;

import com.threerings.util.Name;
import com.threerings.util.ObjectMarshaller;

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.TypedArray;

import com.threerings.presents.dobj.DSet;

import com.threerings.parlor.game.data.GameObject;
import com.threerings.parlor.turn.data.TurnGameObject;

public class WhirledGameObject extends GameObject
    implements TurnGameObject
{
    /** The identifier for a MessageEvent containing a user message. */
    public static const USER_MESSAGE :String = "Umsg";

    /** The identifier for a MessageEvent containing game-system chat. */
    public static const GAME_CHAT :String = "Uchat";

    /** The identifier for a MessageEvent containing ticker notifications. */
    public static const TICKER :String = "Utick";

    /** A message dispatched to each player's client object when flow is awarded. */
    public static const FLOW_AWARDED_MESSAGE :String = "FlowAwarded";

    // AUTO-GENERATED: FIELDS START
    /** The field name of the <code>controllerOid</code> field. */
    public static const CONTROLLER_OID :String = "controllerOid";

    /** The field name of the <code>turnHolder</code> field. */
    public static const TURN_HOLDER :String = "turnHolder";

    /** The field name of the <code>userCookies</code> field. */
    public static const USER_COOKIES :String = "userCookies";

    /** The field name of the <code>whirledGameService</code> field. */
    public static const WHIRLED_GAME_SERVICE :String = "whirledGameService";
    // AUTO-GENERATED: FIELDS END

    /** The client that is in control of this game. The first client to enter will be assigned
     * control and control will subsequently be reassigned if that client disconnects or leaves. */
    public var controllerOid :int;

    /** The current turn holder. */
    public var turnHolder :Name;

    /** A set of loaded user cookies. */
    public var userCookies :DSet;

    /** The set of game data available to this game. */
    public var gameData :TypedArray /* of GameData */;

    /** The service interface for requesting special things from the server. */
    public var whirledGameService :WhirledGameMarshaller;

    /**
     * Access the underlying user properties.
     */
    public function getUserProps () :Object
    {
        return _props;
    }

    // from TurnGameObject
    public function getTurnHolderFieldName () :String
    {
        return TURN_HOLDER;
    }

    // from TurnGameObject
    public function getTurnHolder () :Name
    {
        return turnHolder;
    }

    // from TurnGameObject
    public function getPlayers () :TypedArray /* of Name */
    {
        return players;
    }

    /**
     * Called by a PropertySetEvent to enact a property change.
     * @return the old value
     */
    public function applyPropertySet (propName :String, value :Object, index :int) :Object
    {
        var oldValue :Object = _props[propName];
        if (index >= 0) {
            // set an array element
            var arr :Array = (oldValue as Array);
            if (arr == null) {
                arr = [];
                _props[propName] = arr;
            }
            oldValue = arr[index];
            arr[index] = value;

        } else if (value != null) {
            // normal property set
            _props[propName] = value;

        } else {
            // remove a property
            delete _props[propName];
        }
        return oldValue;
    }

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);

        // first read any regular bits
        readDefaultFields(ins);

        // then user properties
        var count :int = ins.readInt();
        while (count-- > 0) {
            var key :String = ins.readUTF();
            var value :Object = ObjectMarshaller.decode(ins.readObject());
            _props[key] = value;
        }
    }

    /**
     * Reads the fields written by the default serializer for this instance.
     */
    protected function readDefaultFields (ins :ObjectInputStream) :void
    {
        controllerOid = ins.readInt();
        turnHolder = (ins.readObject() as Name);
        userCookies = (ins.readObject() as DSet);
        gameData = (ins.readObject() as TypedArray);
        whirledGameService = (ins.readObject() as WhirledGameMarshaller);
    }
    
    /** The raw properties set by the game. */
    protected var _props :Object = new Object();
}
}
