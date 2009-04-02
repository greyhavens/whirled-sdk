//
// $Id$

package com.whirled.game.loopback {

import com.threerings.util.HashMap;
import com.threerings.util.HashSet;
import com.threerings.util.Integer;
import com.threerings.util.Log;
import com.threerings.util.MethodQueue;
import com.threerings.util.ObjectMarshaller;
import com.threerings.util.StringUtil;
import com.threerings.util.Util;
import com.whirled.ServerObject;
import com.whirled.game.GameControl;
import com.whirled.game.client.PropertySpaceHelper;

import flash.display.DisplayObject;
import flash.errors.IllegalOperationError;
import flash.events.Event;
import flash.utils.ByteArray;
import flash.utils.Dictionary;

public class LoopbackGameControl extends GameControl
{
    public function LoopbackGameControl (disp :DisplayObject, autoReady :Boolean = true)
    {
        if (disp is ServerObject) {
            _serverLoopback = this;
            _myId = SERVER_AGENT_ID;
        } else {
            _playerLoopback = this;
            _myId = LOOPBACK_PLAYER_ID;
        }

        disp.root.loaderInfo.sharedEvents.addEventListener(
            "controlConnect", handleUserCodeConnect, false, int.MAX_VALUE);
        super(disp, autoReady);
    }

    override public function isConnected () :Boolean
    {
        // Always connected
        return true;
    }

    // From here we act like Base
    protected function handleUserCodeConnect (evt :Event) :void
    {
        evt.stopImmediatePropagation();

        // Do everything that BaseGameBackend does
        var props :Object = Object(evt).props;

        var userProps :Object = props.userProps;
        setUserCodeProperties(userProps);

        var ourProps :Object = new Object();
        populateProperties(ourProps);
        props["hostProps"] = ourProps;

        // determine whether to automatically start the game in a backwards compatible way
        var autoReady :Boolean = ("autoReady_v1" in userProps) ? userProps["autoReady_v1"] : true;
    }

    protected function setUserCodeProperties (o :Object) :void
    {
        // here we would handle adapting old functions to a new version
        _userFuncs = o;
    }

    protected function callUserCode (name :String, ... args) :*
    {
        if (_userFuncs != null) {
            try {
                var func :Function = (_userFuncs[name] as Function);
                if (func != null) {
                    return func.apply(null, args);
                }

            } catch (err :Error) {
                reportGameError("Error in user-code: " + err, err);
            }
        }
        return undefined;
    }

    protected function populateProperties (o :Object) :void
    {
        // straight data
        o["gameData"] = _gameData;

        // convert our game config from a HashMap to a Dictionary
        /*var gameConfig :Object = {};
        var cfg :BaseGameConfig = getConfig();
        cfg.params.forEach(function (key :Object, value :Object) :void {
            gameConfig[key] = (value is Boxed) ? Boxed(value).unbox() : value;
        });
        o["gameConfig"] = gameConfig;
        o["gameInfo"] = createGameInfo();*/

        // GameControl
        o["commitTransaction"] = commitTransaction_v1;
        o["startTransaction"] = startTransaction_v1;

        // .net
        o["sendMessage_v2"] = sendMessage_v2;
        o["setProperty_v2"] = setProperty_v2;
        o["testAndSetProperty_v1"] = testAndSetProperty_v1;

        // .player
        o["getUserCookie_v2"] = getUserCookie_v2;
        o["getCookie_v1"] = getCookie_v1;
        o["setUserCookie_v1"] = setUserCookie_v1;
        o["setCookie_v1"] = setCookie_v1;
        o["holdsTrophy_v1"] = holdsTrophy_v1;
        o["awardTrophy_v1"] = awardTrophy_v1;
        o["awardPrize_v1"] = awardPrize_v1;
        o["getPlayerItemPacks_v1"] = getPlayerItemPacks_v1;
        o["getPlayerLevelPacks_v1"] = getPlayerLevelPacks_v1;

        // .game
        //o["endGame_v2"] = endGame_v2;
        //o["endGameWithScores_v1"] = endGameWithScores_v1;
        //o["endGameWithWinners_v1"] = endGameWithWinners_v1;
        //o["endRound_v1"] = endRound_v1;
        o["getControllerId_v1"] = getControllerId_v1;
        o["getLevelPacks_v2"] = getLevelPacks_v2;
        o["getItemPacks_v1"] = getItemPacks_v1;
        o["loadLevelPackData_v1"] = loadLevelPackData_v1;
        o["loadItemPackData_v1"] = loadItemPackData_v1;
        o["getOccupants_v1"] = getOccupants_v1;
        o["getOccupantName_v1"] = getOccupantName_v1;
        //o["getRound_v1"] = getRound_v1;
        //o["getTurnHolder_v1"] = getTurnHolder_v1;
        //o["isInPlay_v1"] = isInPlay_v1;
        //o["restartGameIn_v1"] = restartGameIn_v1;
        o["sendChat_v1"] = sendChat_v1;
        //o["startNextTurn_v1"] = startNextTurn_v1;
        o["getMyId_v1"] = getMyId_v1;

        // .game.seating
        o["getPlayers_v1"] = getPlayers_v1;
        o["getPlayerPosition_v1"] = getPlayerPosition_v1;
        o["getMyPosition_v1"] = getMyPosition_v1;

        // .services
        //o["checkDictionaryWord_v2"] = checkDictionaryWord_v2;
        //o["getDictionaryLetterSet_v2"] = getDictionaryLetterSet_v2;
        //o["getDictionaryWords_v1"] = getDictionaryWords_v1;
        //o["setTicker_v1"] = setTicker_v1;

        // .services.bags
        //o["getFromCollection_v2"] = getFromCollection_v2;
        //o["mergeCollection_v1"] = mergeCollection_v1;
        //o["populateCollection_v1"] = populateCollection_v1;

        // Old methods: backwards compatability
        //o["awardFlow_v1"] = awardFlow_v1;
        //o["awardFlow_v2"] = awardFlow_v2;
        //o["checkDictionaryWord_v1"] = checkDictionaryWord_v1;
        //o["endTurn_v2"] = startNextTurn_v1; // it's the same!
        //o["getAvailableFlow_v1"] = getAvailableFlow_v1;
        //o["getDictionaryLetterSet_v1"] = getDictionaryLetterSet_v1;
        //o["setProperty_v1"] = setProperty_v1;
        //o["getLevelPacks_v1"] = getLevelPacks_v1;
    }

    //---- GameControl -----------------------------------------------------

    /**
     * Starts a transaction that will group all game state changes into a single message.
     */
    protected function startTransaction_v1 () :void
    {
        // increment our transaction nesting count
        if (_transactionCount++ == 0) {
            _curTransaction = [];
        }
    }

    /**
     * Commits a transaction started with <code>startTransaction_v1</code>.
     */
    protected function commitTransaction_v1 () :void
    {
        if (_transactionCount <= 0) {
            throw new IllegalOperationError("Cannot commit: not involved in a transaction");
        }
        if (--_transactionCount == 0) {
            for each (var op :Function in _curTransaction) {
                MethodQueue.callLater(op);
            }

            _curTransaction = null;
        }
    }

    //---- .net ------------------------------------------------------------

    protected function sendMessage_v2 (messageName :String, value :Object, playerId :int) :void
    {
        validateName(messageName);
        validateValue(value);

        var messageOp :Function = function () :void {
            if ((playerId == TO_ALL || playerId == LOOPBACK_PLAYER_ID) && _playerLoopback != null) {
                _playerLoopback.callUserCode("messageReceived_v2", messageName, value, _myId);
            }

            if ((playerId == TO_ALL || playerId == SERVER_AGENT_ID) && _serverLoopback != null) {
                _serverLoopback.callUserCode("messageReceived_v2", messageName, value, _myId);
            }
        };

        if (_transactionCount > 0) {
            _curTransaction.push(messageOp);
        } else {
            MethodQueue.callLater(messageOp);
        }
    }

    /**
     * Sets a property.
     *
     * Note: immediate defaults to true, even though immediate=false is the general case. We are
     * providing some backwards compatibility to old versions of setProperty_v1() that assumed
     * immediate and did not pass a 4th value.  All callers should now specify that value
     * explicitly.
     */
    protected function setProperty_v2 (
        propName :String, value :Object, key :Object, isArray :Boolean, immediate :Boolean) :void
    {
        validatePropertyChange(propName, value, isArray, int(key));

        var encoded :Object = PropertySpaceHelper.encodeProperty(value, (key == null));
        var ikey :Integer = (key == null) ? null : new Integer(int(key));
        if (immediate) {
            // we re-decode so that it looks like it came off the net
            try {
                applyPropertySet(
                    _gameData, propName, PropertySpaceHelper.decodeProperty(encoded), key, isArray);
            } catch (re :RangeError) {
                trace("Error setting property (immediate): " + re);
            }
        }

        var propOp :Function = function () :void {
            updateProp(propName, encoded, ikey, isArray);
            if (this.otherLoopback != null) {
                this.otherLoopback.updateProp(propName, encoded, ikey, isArray);
            }
        };

        if (_transactionCount > 0) {
            _curTransaction.push(propOp);
        } else {
            MethodQueue.callLater(propOp);
        }
    }

    /**
     * Test and set a property. Note that the 'index' parameter was deprecated on 2008-02-20.
     * Newer code will only pass in propName, value, testValue. Older code will also pass in the
     * index, but that's ok as long as it's -1.
     */
    protected function testAndSetProperty_v1 (
        propName :String, value :Object, testValue :Object, index :int = -1) :void
    {
        if (index != -1) {
            throw new Error("Sorry, using testAndSet with an index value is no longer supported. " +
                "Update your SDK.");
        }
        validatePropertyChange(propName, value, false, 0);

        var encodedValue :Object = PropertySpaceHelper.encodeProperty(value, true);
        var encodedTestValue :Object = PropertySpaceHelper.encodeProperty(testValue, true);

        var propOp :Function = function () :void {
            var encodedCurValue :Object =
                PropertySpaceHelper.encodeProperty(_gameData[propName], true);
            if (Util.equals(encodedTestValue, encodedCurValue)) {
                updateProp(propName, encodedValue, null, false);
                if (this.otherLoopback != null) {
                    this.otherLoopback.updateProp(propName, encodedValue, null, false);
                }
            }
        };

        if (_transactionCount > 0) {
            _curTransaction.push(propOp);
        } else {
            MethodQueue.callLater(propOp);
        }
    }

    protected function updateProp (propName :String, encodedVal :Object, ikey :Integer,
        isArray :Boolean) :void
    {
        var value :Object = PropertySpaceHelper.decodeProperty(encodedVal);
        var keyObj :Object = (ikey == null) ? null : ikey.value;
        var oldValue :Object;
        try {
            oldValue = applyPropertySet(_gameData, propName, value, keyObj, isArray);
        } catch (re :RangeError) {
            trace("Error setting property: " + re);
            return;
        }

        callUserCode("propertyWasSet_v2", propName, value, oldValue, keyObj);
    }

    //---- .player ---------------------------------------------------------

    protected function getUserCookie_v2 (playerId :int, callback :Function) :void
    {
        getCookie_v1(function (cookie :Object, ...unused) :void {
            callback(cookie);
        }, playerId);
    }

    protected function getCookie_v1 (callback :Function, occupantId :int) :void
    {
        if (occupantId == CURRENT_USER) {
            occupantId = getMyId_v1();
            if (occupantId == SERVER_AGENT_ID) {
                throw new Error("Server agent must provide a player id here");
            }
        }

        var cookieBytes :ByteArray = (_userCookies.get(occupantId) as ByteArray);
        var cookie :Object = (cookieBytes != null ? ObjectMarshaller.decode(cookieBytes) : null);
        callback(cookie, occupantId);
    }

    protected function setUserCookie_v1 (cookie :Object, playerId :int = CURRENT_USER) :Boolean
    {
        return setCookie_v1(cookie, playerId);
    }

    protected function setCookie_v1 (cookie :Object, occupantId :int = CURRENT_USER) :Boolean
    {
        validateValue(cookie);

        if (occupantId == CURRENT_USER) {
            occupantId = getMyId_v1();
            if (occupantId == SERVER_AGENT_ID) {
                throw new Error("Server agent must provide a player id here");
            }
        }

        var ba :ByteArray = (ObjectMarshaller.encode(cookie, false) as ByteArray);
        if (ba.length > MAX_USER_COOKIE) {
            // not saved!
            return false;
        }

        receiveUserCookie(occupantId, ba);
        if (this.otherLoopback != null) {
            this.otherLoopback.receiveUserCookie(occupantId, ba);
        }

        return true;
    }

    protected function receiveUserCookie (occupantId :int, cookieBytes :ByteArray) :void
    {
        _userCookies.put(occupantId, cookieBytes);
    }

    protected function holdsTrophy_v1 (ident :String, playerId :int = CURRENT_USER) :Boolean
    {
        if (playerId == CURRENT_USER) {
            playerId = getMyId_v1();
            if (playerId == SERVER_AGENT_ID) {
                throw new Error("Server agent must provide a player id here");
            }
        }

        if (playerId == LOOPBACK_PLAYER_ID && _playerLoopback != null) {
            return _playerLoopback._awardedTrophies.contains(ident);
        } else {
            return false;
        }
    }

    protected function awardTrophy_v1 (ident :String, playerId :int = CURRENT_USER) :Boolean
    {
        if (playerId == CURRENT_USER) {
            playerId = getMyId_v1();
            if (playerId == SERVER_AGENT_ID) {
                throw new Error("Server agent must provide a player id here");
            }
        }

        if (holdsTrophy_v1(ident, playerId)) {
            return false;
        }

        if (playerId == LOOPBACK_PLAYER_ID) {
            _playerLoopback._awardedTrophies.add(ident);
            return true;
        }

        return false;
    }

    protected function awardPrize_v1 (ident :String, playerId :int = CURRENT_USER) :void
    {
        // no-op
    }

    protected function getPlayerItemPacks_v1 (playerId :int = CURRENT_USER) :Array
    {
        // no-op
        return [];
    }

    protected function getPlayerLevelPacks_v1 (playerId :int = CURRENT_USER) :Array
    {
        // no-op
        return [];
    }

    //---- .game -----------------------------------------------------------

    protected function sendChat_v1 (msg :String) :void
    {
        validateChat(msg);

        var chatOp :Function = function () :void {
            if (_playerLoopback != null) {
                _playerLoopback.receiveChat(_myId, msg);
            }
            if (_serverLoopback != null) {
                _serverLoopback.receiveChat(_myId, msg);
            }
        };

        MethodQueue.callLater(chatOp);
    }

    protected function getLevelPacks_v2 (filter :Function = null) :Array
    {
        // no-op
        return [];
    }

    protected function getItemPacks_v1 (filter :Function = null) :Array
    {
        // no-op
        return [];
    }

    protected function loadLevelPackData_v1 (
        ident :String, onLoaded :Function, onFailure :Function) :void
    {
        if (onFailure != null) {
            onFailure(new Error("Unknown data pack: " + ident));
        }
    }

    protected function loadItemPackData_v1 (
        ident :String, onLoaded :Function, onFailure :Function) :void
    {
        if (onFailure != null) {
            onFailure(new Error("Unknown data pack: " + ident));
        }
    }

    protected function receiveChat (senderId :int, msg :String) :void
    {
        callUserCode("userChat_v1", senderId, msg);
    }

    protected function getControllerId_v1 () :int
    {
        return (_playerLoopback != null ? LOOPBACK_PLAYER_ID : 0);
    }

    protected function getOccupants_v1 () :Array
    {
        return (_playerLoopback != null ? [ LOOPBACK_PLAYER_ID ] : []);
    }

    protected function getOccupantName_v1 (playerId :int) :String
    {
        return (playerId == LOOPBACK_PLAYER_ID ? "Loopback Player" : null);
    }

    protected function getMyId_v1 () :int
    {
        return _myId;
    }

    //---- .game.seating ---------------------------------------------------

    protected function getPlayerPosition_v1 (playerId :int) :int
    {
        return (playerId == LOOPBACK_PLAYER_ID ? 0 : -1);
    }

    protected function getPlayers_v1 () :Array
    {
        return (_playerLoopback != null ? [ LOOPBACK_PLAYER_ID ] : []);
    }

    protected function getMyPosition_v1 () :int
    {
        return getPlayerPosition_v1(_myId);
    }

    /**
     * Verify that the property name / value are valid.
     */
    protected function validatePropertyChange (
        propName :String, value :Object, array :Boolean, index :int) :void
    {
        validateName(propName);

        if (array) {
            if (index < 0) {
                throw new ArgumentError("Bogus array index specified.");
            }
            if (!(_gameData[propName] is Array)) {
                throw new ArgumentError("Property " + propName + " is not an Array.");
            }
        }

        // validate the value too
        validateValue(value);
    }

    /**
     * Verify that the specified name is valid.
     */
    protected function validateName (name :String) :void
    {
        if (name == null) {
            throw new ArgumentError("Property, message, and collection names must not be null.");
        }
    }

    /**
     * Verify that the supplied chat message is valid.
     */
    protected function validateChat (msg :String) :void
    {
        if (StringUtil.isBlank(msg)) {
            throw new ArgumentError("Empty chat may not be displayed.");
        }
    }

    /**
     * Verify that the value is legal to be streamed to other clients.
     */
    protected function validateValue (value :Object) :void
    {
        ObjectMarshaller.validateValue(value);
    }

    /**
     * Log the specified game error message.
     */
    protected function reportGameError (msg :String, err :Error = null) :void
    {
        // here, we just shoot this to the logs
        log.warning(msg);
        if (err != null) {
            log.logStackTrace(err);
        }
    }

    protected function get otherLoopback () :LoopbackGameControl
    {
        return (this == _playerLoopback ? _serverLoopback : _playerLoopback);
    }

    /**
     * Enacts a property change.
     * @return the old value
     *
     * @throws RangeError if the key is out of range (arrays only)
     */
    protected static function applyPropertySet (
        props :Object, propName :String, value :Object,
        key :Object, isArray :Boolean) :Object
    {
        var oldValue :Object = props[propName];
        if (key != null) {
            var index :int = int(key);
            if (isArray) {
                if (!(oldValue is Array)) {
                    throw new RangeError("Current value is not an Array.");
                }
                var arr :Array = (oldValue as Array);
                if (index < 0 || index >= arr.length) {
                    throw new RangeError("Array index out of range.");
                }
                oldValue = arr[index];
                arr[index] = value;

            } else {
                var dict :Dictionary = (oldValue as Dictionary);
                if (dict == null) {
                    dict = new Dictionary(); // force creation
                    props[propName] = dict;
                }
                oldValue = dict[index];
                if (value == null) {
                    delete dict[index];
                } else {
                    dict[index] = value;
                }
            }

        } else if (value != null) {
            // normal property set
            props[propName] = value;

        } else {
            // remove a property
            delete props[propName];
        }
        return oldValue;
    }

    protected var _myId :int;
    protected var _userFuncs :Object;
    protected var _gameData :Object = new Object();

    protected var _userCookies :HashMap = new HashMap();
    protected var _awardedTrophies :HashSet = new HashSet();

    protected var _curTransaction :Array;
    protected var _transactionCount :int;

    protected var log :Log = Log.getLog(this);

    protected static var _playerLoopback :LoopbackGameControl;
    protected static var _serverLoopback :LoopbackGameControl;

    protected static const LOOPBACK_PLAYER_ID :int = 1
    protected static const SERVER_AGENT_ID :int = int.MIN_VALUE;

    protected static const TO_ALL :int = 0;

    protected static const MAX_USER_COOKIE :int = 4096;

    protected static const CURRENT_USER :int = 0;
}

}
