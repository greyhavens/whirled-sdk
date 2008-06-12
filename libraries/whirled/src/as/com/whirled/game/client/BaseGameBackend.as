//
// $Id$

package com.whirled.game.client {

import flash.events.Event;
import flash.events.IEventDispatcher;

import flash.utils.Dictionary;

import com.threerings.io.TypedArray;

import com.threerings.util.Integer;
import com.threerings.util.Log;
import com.threerings.util.MessageBundle;
import com.threerings.util.Name;
import com.threerings.util.ObjectMarshaller;
import com.threerings.util.StringUtil;
import com.threerings.util.Wrapped;

import com.threerings.presents.client.ConfirmAdapter;
import com.threerings.presents.client.ResultWrapper;
import com.threerings.presents.client.InvocationService_ConfirmListener;
import com.threerings.presents.client.InvocationService_ResultListener;

import com.threerings.presents.dobj.ElementUpdateListener;
import com.threerings.presents.dobj.ElementUpdatedEvent;
import com.threerings.presents.dobj.EntryAddedEvent;
import com.threerings.presents.dobj.EntryRemovedEvent;
import com.threerings.presents.dobj.EntryUpdatedEvent;
import com.threerings.presents.dobj.MessageAdapter;
import com.threerings.presents.dobj.MessageEvent;
import com.threerings.presents.dobj.MessageListener;
import com.threerings.presents.dobj.SetListener;

import com.threerings.presents.util.PresentsContext;

import com.threerings.crowd.chat.client.ChatDisplay;
import com.threerings.crowd.chat.data.ChatCodes;
import com.threerings.crowd.chat.data.ChatMessage;
import com.threerings.crowd.chat.data.UserMessage;

import com.threerings.crowd.data.OccupantInfo;
import com.threerings.crowd.data.PlaceObject;

import com.threerings.parlor.game.data.GameConfig;
import com.threerings.parlor.game.data.GameObject;

import com.whirled.game.data.GameData;
import com.whirled.game.data.ItemData;
import com.whirled.game.data.LevelData;
import com.whirled.game.data.PropertySetEvent;
import com.whirled.game.data.PropertySetListener;
import com.whirled.game.data.TrophyData;
import com.whirled.game.data.UserCookie;
import com.whirled.game.data.BaseGameConfig;
import com.whirled.game.data.WhirledGameCodes;
import com.whirled.game.data.WhirledGameObject;
import com.whirled.game.data.WhirledGameOccupantInfo;

/**
 * Manages the backend of the game.
 */
public class BaseGameBackend
    implements MessageListener, SetListener, ElementUpdateListener, PropertySetListener, ChatDisplay
{
    public var log :Log = Log.getLog(this);

    public function BaseGameBackend (
        ctx :PresentsContext, gameObj :WhirledGameObject)
    {
        _ctx = ctx;
        _gameObj = gameObj;
        _gameData = _gameObj.getUserProps();

        _gameObj.addListener(this);
        _ctx.getClient().getClientObject().addListener(_userListener);
    }

    public function forceClassInclusion () :void
    {
        var c :Class;
        c = GameData;
        c = LevelData;
        c = ItemData;
        c = TrophyData;
    }

    public function setSharedEvents (disp :IEventDispatcher) :void
    {
        // old style listener. Deprecated 2008-02-15, but we'll probably always need it
        disp.addEventListener("ezgameQuery", handleUserCodeConnect);
        // newer listener
        disp.addEventListener("controlConnect", handleUserCodeConnect);
    }

    /**
     * Are we connected to the usercode on the front-end?
     */
    public function isConnected () :Boolean
    {
        return (_userFuncs != null);
    }

    public function shutdown () :void
    {
        _gameObj.removeListener(this);
        _ctx.getClient().getClientObject().removeListener(_userListener);
        callUserCode("connectionClosed_v1");
        _userFuncs = null; // disconnect
    }

    /**
     * Validate that we're not shutdown.
     */
    public function validateConnected () :void
    {
        if (_userFuncs == null) {
            throw new Error("Not connected.");
        }
    }

    /**
     * Called by the BaseGameController when the controller changes.
     */
    public function controlDidChange () :void
    {
        callUserCode("controlDidChange_v1");
    }

    /**
     * Called by the BaseGameController when the turn changes.
     */
    public function turnDidChange () :void
    {
        callUserCode("turnDidChange_v1");
    }

    /**
     * Called by the BaseGameController when the game starts or ends.
     */
    public function gameStateChanged (started :Boolean) :void
    {
        if (_userFuncs == null) {
            // Normally this is not needed, because callUserCode will fail gracefully if we're
            // not connected. However, this method accesses _userFuncs directly, and it may not
            // yet be set up if the user is still downloading the game media.
            return;
        }
        if (started && _userFuncs["gameDidStart_v1"] != null) {
            callUserCode("gameDidStart_v1"); // backwards compatibility
        } else if (!started && _userFuncs["gameDidEnd_v1"] != null) {
            callUserCode("gameDidEnd_v1"); // backwards compatibility
        } else {
            callUserCode("gameStateChanged_v1", started); // new hotness
        }
    }

    /**
     * Called by the BaseGameController when a round starts or ends.
     */
    public function roundStateChanged (started :Boolean) :void
    {
        callUserCode("roundStateChanged_v1", started);
    }

    // from SetListener
    public function entryAdded (event :EntryAddedEvent) :void
    {
        var name :String = event.getName();
        switch (name) {
        case WhirledGameObject.USER_COOKIES:
            receivedUserCookie(event.getEntry() as UserCookie);
            break;

        case PlaceObject.OCCUPANT_INFO:
            var occInfo :OccupantInfo = (event.getEntry() as OccupantInfo)
            if (isInited(occInfo)) {
                callUserCode("occupantChanged_v1", occInfo.bodyOid, isPlayer(occInfo.username),
                    true);
            }
            break;
        }
    }

    // from SetListener
    public function entryUpdated (event :EntryUpdatedEvent) :void
    {
        var name :String = event.getName();
        switch (name) {
        case WhirledGameObject.USER_COOKIES:
            receivedUserCookie(event.getEntry() as UserCookie);
            break;

        case PlaceObject.OCCUPANT_INFO:
            var occInfo :WhirledGameOccupantInfo = (event.getEntry() as WhirledGameOccupantInfo);
            var oldInfo :WhirledGameOccupantInfo = (event.getOldEntry() as WhirledGameOccupantInfo);
            // Only report someone else if they transitioned from uninitialized to initialized
            // Note that our own occupantInfo will never pass this test, that is correct.
            if (!isInited(oldInfo) && isInited(occInfo)) {
                callUserCode("occupantChanged_v1", occInfo.bodyOid, isPlayer(occInfo.username),
                    true);
            }
            break;
        }
    }

    // from SetListener
    public function entryRemoved (event :EntryRemovedEvent) :void
    {
        var name :String = event.getName();
        switch (name) {
        case PlaceObject.OCCUPANT_INFO:
            var occInfo :OccupantInfo = (event.getOldEntry() as OccupantInfo)
            if (isInited(occInfo)) {
                callUserCode("occupantChanged_v1", occInfo.bodyOid, isPlayer(occInfo.username),
                    false);
            }
            break;
        }
    }

    // from ElementUpdateListener
    public function elementUpdated (event :ElementUpdatedEvent) :void
    {
        var name :String = event.getName();
        if (name == GameObject.PLAYERS) {
            var oldPlayer :Name = (event.getOldValue() as Name);
            var newPlayer :Name = (event.getValue() as Name);
            var occInfo :OccupantInfo;
            if (oldPlayer != null) {
                occInfo = _gameObj.getOccupantInfo(oldPlayer);
                if (isInited(occInfo)) {
                    // old player became a watcher
                    // send player-left, then occupant-added
                    callUserCode("occupantChanged_v1", occInfo.bodyOid, true, false);
                    callUserCode("occupantChanged_v1", occInfo.bodyOid, false, true);
                }
            }
            if (newPlayer != null) {
                occInfo = _gameObj.getOccupantInfo(newPlayer);
                if (isInited(occInfo)) {
                    // watcher became a player
                    // send occupant-left, then player-added
                    callUserCode("occupantChanged_v1", occInfo.bodyOid, false, false);
                    callUserCode("occupantChanged_v1", occInfo.bodyOid, true, true);
                }
            }
        }
    }

    // from MessageListener
    public function messageReceived (event :MessageEvent) :void
    {
        var name :String = event.getName();
        if (WhirledGameObject.USER_MESSAGE == name) {
            var args :Array = event.getArgs();
            var mname :String = (args[0] as String);
            var data :Object = ObjectMarshaller.decode(args[1]);
            var senderId :int = (args[2] as int);
            dispatchMessageReceived(mname, data, senderId);
        } else if (WhirledGameObject.TICKER == name) {
            var targs :Array = event.getArgs();
            dispatchMessageReceived((targs[0] as String), (targs[1] as int), 0);
        }
    }

    // from PropertySetListener
    public function propertyWasSet (event :PropertySetEvent) :void
    {
        if (_userFuncs == null) {
            // Normally this is not needed, because callUserCode will fail gracefully if we're
            // not connected. However, this method accesses _userFuncs directly, and it may not
            // yet be set up if the user is still downloading the game media.
            return;
        }
        var key :Integer = event.getKey();
        if ("propertyWasSet_v1" in _userFuncs) {
            // dispatch the old way (Deprecated 2008-02-20, but we'll probably always need it)
            var index :int = (key == null) ? -1 : key.value;
            callUserCode("propertyWasSet_v1", event.getName(), event.getValue(),
                event.getOldValue(), index);

        } else {
            // dispatch the new way
            var keyObj :Object = (key == null) ? null : key.value;
            callUserCode("propertyWasSet_v2", event.getName(), event.getValue(),
                event.getOldValue(), keyObj);
        }
    }

    // from ChatDisplay
    public function clear () :void
    {
        // we do nothing
    }

    // from ChatDisplay
    public function displayMessage (msg :ChatMessage, alreadyDisplayed :Boolean) :Boolean
    {
        if (msg is UserMessage && msg.localtype == ChatCodes.PLACE_CHAT_TYPE) {
            var occInfo :OccupantInfo = _gameObj.getOccupantInfo((msg as UserMessage).speaker);
            // the game doesn't hear about the chat until the speaker is initialized
            if (isInited(occInfo)) {
                callUserCode("userChat_v1", occInfo.bodyOid, msg.message);
            }
        }
        return true;
    }

    /**
     * Lets the controller know that our user code is now ready to run. Does nothing by default,
     * so subclasses should override.
     */
    protected function notifyControllerUserCodeIsConnected (autoReady :Boolean) :void
    {
    }

    /**
     * Access the configuration of our game. This is an abstract method and must be provided
     * by subclasses.
     */
    protected function getConfig () :BaseGameConfig
    {
        throw new Error("Abstract method");
    }

    /**
     * Create a logging confirm listener for service requests.
     */
    protected function createLoggingConfirmListener (
        service :String) :InvocationService_ConfirmListener
    {
        return new ConfirmAdapter(function (cause :String) :void {
            logGameError("Service failure [service=" + service + ", cause=" + cause + "].");
        });
    }

    /**
     * Create a logging result listener for service requests.
     */
    protected function createLoggingResultListener (
        service :String) :InvocationService_ResultListener
    {
        return new ResultWrapper(function (cause :String) :void {
            logGameError("Service failure [service=" + service + ", cause=" + cause + "].");
        });
    }

    /**
     * Log the specified game error message.
     */
    protected function logGameError (msg :String, err :Error = null) :void
    {
        // here, we just shoot this to the logs
        log.warning(msg);
        if (err != null) {
            log.logStackTrace(err);
        }
    }

    /**
     * Helper for various occupantInfo-related bits.
     * Returns true if the occupant info is not null and is reportable to the usercode.
     */
    protected function isInited (occInfo :OccupantInfo) :Boolean
    {
        return (occInfo != null) &&
            ((occInfo as WhirledGameOccupantInfo).initialized ||
             (occInfo.bodyOid == _ctx.getClient().getClientOid()));
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
     * Called by our user listener when we receive a message event on the user object.
     */
    protected function messageReceivedOnUserObject (event :MessageEvent) :void
    {
        var name :String = event.getName();
        if (name == (WhirledGameObject.USER_MESSAGE + ":" + _gameObj.getOid())) {
            var args :Array = event.getArgs();
            var mname :String = (args[0] as String);
            var data :Object = ObjectMarshaller.decode(args[1]);
            var senderId :int = (args[2] as int);
            dispatchMessageReceived(mname, data, senderId);
        }
    }

    /**
     * Handle the arrival of a new UserCookie.
     */
    protected function receivedUserCookie (cookie :UserCookie) :void
    {
        if (_cookieCallbacks != null) {
            var arr :Array = (_cookieCallbacks[cookie.playerId] as Array);
            if (arr != null) {
                delete _cookieCallbacks[cookie.playerId];
                for each (var fn :Function in arr) {
                    // we want to decode every time, in case usercode mangles the value
                    var decodedValue :Object = ObjectMarshaller.decode(cookie.cookie);
                    try {
                        fn(decodedValue);
                    } catch (err :Error) {
                        logGameError("Error in user-code: " + err, err);
                    }
                }
            }
        }
    }

    /**
     * Given the specified occupant name, return if they are a player.
     */
    protected function isPlayer (occupantName :Name) :Boolean
    {
        if (_gameObj.players.length == 0) {
            return true; // party game: all occupants are players
        }
        return (-1 != _gameObj.getPlayerIndex(occupantName));
    }

    protected function handleUserCodeConnect (evt :Event) :void
    {
        var props :Object = ("props" in evt) ? Object(evt).props : evt;

        // Old-style queries were deprecated 2008-02-18, but we'll probably always need them.
        // Old: eventName: "ezQuery", userProps: "userProps", ourProps: "ezProps"
        // New: eventName: "controlConnect", userProps: "userProps", ourProps: "hostProps"
        var hostPropName :String = (evt.type == "controlConnect") ? "hostProps" : "ezProps";

        var userProps :Object = props.userProps;
        setUserCodeProperties(userProps);

        var ourProps :Object = new Object();
        populateProperties(ourProps);
        props[hostPropName] = ourProps;

        // determine whether to automatically start the game in a backwards compatible way
        var autoReady :Boolean = ("autoReady_v1" in userProps) ? userProps["autoReady_v1"] : true;

        // ok, we're now hooked-up with the game code
        notifyControllerUserCodeIsConnected(autoReady);
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
                logGameError("Error in user-code: " + err, err);
            }
        }
        return undefined;
    }

    protected function populateProperties (o :Object) :void
    {
        // straight data
        o["gameData"] = _gameData;

        // convert our game config from a HashMap to a Dictionary
        var gameConfig :Object = {};
        var cfg :BaseGameConfig = getConfig();
        cfg.params.forEach(function (key :Object, value :Object) :void {
            gameConfig[key] = (value is Wrapped) ? Wrapped(value).unwrap() : value;
        });
        o["gameConfig"] = gameConfig;
        o["gameInfo"] = createGameInfo();

        // GameControl
        o["commitTransaction"] = commitTransaction_v1;
        o["startTransaction"] = startTransaction_v1;

        // .net
        o["sendMessage_v2"] = sendMessage_v2;
        o["setProperty_v2"] = setProperty_v2;
        o["testAndSetProperty_v1"] = testAndSetProperty_v1;

        // .player
        o["getUserCookie_v2"] = getUserCookie_v2;

        // .game
        o["endGame_v2"] = endGame_v2;
        o["endGameWithScores_v1"] = endGameWithScores_v1;
        o["endGameWithWinners_v1"] = endGameWithWinners_v1;
        o["endRound_v1"] = endRound_v1;
        o["getControllerId_v1"] = getControllerId_v1;
        o["getItemPacks_v1"] = getItemPacks_v1;
        o["getLevelPacks_v1"] = getLevelPacks_v1;
        o["getOccupants_v1"] = getOccupants_v1;
        o["getOccupantName_v1"] = getOccupantName_v1;
        o["getRound_v1"] = getRound_v1;
        o["getTurnHolder_v1"] = getTurnHolder_v1;
        o["isInPlay_v1"] = isInPlay_v1;
        o["restartGameIn_v1"] = restartGameIn_v1;
        o["sendChat_v1"] = sendChat_v1;
        o["startNextTurn_v1"] = startNextTurn_v1;
        o["getMyId_v1"] = getMyId_v1;

        // .game.seating
        o["getPlayers_v1"] = getPlayers_v1;
        o["getPlayerPosition_v1"] = getPlayerPosition_v1;

        // .services
        o["checkDictionaryWord_v2"] = checkDictionaryWord_v2;
        o["getDictionaryLetterSet_v2"] = getDictionaryLetterSet_v2;
        o["setTicker_v1"] = setTicker_v1;

        // .services.bags
        o["getFromCollection_v2"] = getFromCollection_v2;
        o["mergeCollection_v1"] = mergeCollection_v1;
        o["populateCollection_v1"] = populateCollection_v1;

        // Old methods: backwards compatability
        o["awardFlow_v1"] = awardFlow_v1;
        o["awardFlow_v2"] = awardFlow_v2;
        o["checkDictionaryWord_v1"] = checkDictionaryWord_v1;
        o["endTurn_v2"] = startNextTurn_v1; // it's the same!
        o["getAvailableFlow_v1"] = getAvailableFlow_v1;
        o["getDictionaryLetterSet_v1"] = getDictionaryLetterSet_v1;
        o["setProperty_v1"] = setProperty_v1;
    }

    /**
     * Populate a small gameInfo property to communicate attributes to clients.
     */
    protected function createGameInfo () :Object
    {
        var o :Object = {};

        // for now, all we indicate is the game type
        o["type"] = getGameInfoType();

        return o;
    }

    /**
     * Get a String name for the game type.
     */
    protected function getGameInfoType () :String
    {
        var cfg :BaseGameConfig = getConfig();
        switch (cfg.getMatchType()) {
        case GameConfig.SEATED_GAME:
            return "seated";
        case GameConfig.SEATED_CONTINUOUS:
            return "seated_continuous";
        case GameConfig.PARTY:
            return "party";
        default:
            return "unknown";
        }
    }

    /**
     * Disatpch a message to the right version of the messageReceived function.
     */
    protected function dispatchMessageReceived (
        mname :String, data :Object, senderId :int) :void
    {
        if ("messageReceived_v2" in _userFuncs) {
            callUserCode("messageReceived_v2", mname, data, senderId);
        } else {
            callUserCode("messageReceived_v1", mname, data);
        }
    }

    //---- GameControl -----------------------------------------------------

    /**
     * Starts a transaction that will group all game state changes into a single message.
     */
    protected function startTransaction_v1 () :void
    {
        validateConnected();
        _ctx.getClient().getInvocationDirector().startTransaction();
    }

    /**
     * Commits a transaction started with {@link #startTransaction_v1}.
     */
    protected function commitTransaction_v1 () :void
    {
        _ctx.getClient().getInvocationDirector().commitTransaction();
    }

    //---- .net ------------------------------------------------------------

    protected function sendMessage_v2 (messageName :String, value :Object, playerId :int) :void
    {
        validateConnected();
        validateName(messageName);
        validateValue(value);

        var encoded :Object = ObjectMarshaller.encode(value, false);
        _gameObj.whirledGameService.sendMessage(_ctx.getClient(), messageName, encoded, playerId,
                                         createLoggingConfirmListener("sendMessage"));
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
        validateConnected();
        validatePropertyChange(propName, value, isArray, int(key));

        var encoded :Object = WhirledGameObject.encodeProperty(value, (key == null));
        var ikey :Integer = (key == null) ? null : new Integer(int(key));
        _gameObj.whirledGameService.setProperty(
            _ctx.getClient(), propName, encoded, ikey, isArray,
            false, null, createLoggingConfirmListener("setProperty"));
        if (immediate) {
            // we re-decode so that it looks like it came off the net
            try {
                _gameObj.applyPropertySet(propName, WhirledGameObject.decodeProperty(encoded),
                    key, isArray);
            } catch (re :RangeError) {
                trace("Error setting property (immediate): " + re);
            }
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
        // very naughty hack to support old setProperty semantics for auto-sizing arrays,
        // since Defense relies on them. TODO: robert, remove after your game is fixed up!
        if (value is Array && value.length == 0 && provideArrayCompatibility()) {
            value.length = 1000; 
        }

        if (index != -1) {
            throw new Error("Sorry, using testAndSet with an index value is no longer supported. " +
                "Update your SDK.");
        }
        validateConnected();
        validatePropertyChange(propName, value, false, 0);

        var encodedValue :Object = WhirledGameObject.encodeProperty(value, true);
        var encodedTestValue :Object = WhirledGameObject.encodeProperty(testValue, true);
        _gameObj.whirledGameService.setProperty(
            _ctx.getClient(), propName, encodedValue, null, false, true, encodedTestValue,
            createLoggingConfirmListener("testAndSetProperty"));
    }

    //---- .player ---------------------------------------------------------

    protected function getUserCookie_v2 (playerId :int, callback :Function) :void
    {
        validateConnected();
        // see if that cookie is already published
        if (_gameObj.userCookies != null) {
            var uc :UserCookie = (_gameObj.userCookies.get(playerId) as UserCookie);
            if (uc != null) {
                callback(ObjectMarshaller.decode(uc.cookie));
                return;
            }
        }

        if (_cookieCallbacks == null) {
            _cookieCallbacks = new Dictionary();
        }
        var arr :Array = (_cookieCallbacks[playerId] as Array);
        if (arr == null) {
            arr = [];
            _cookieCallbacks[playerId] = arr;
        }
        arr.push(callback);

        // request it to be made so by the server
        _gameObj.whirledGameService.getCookie(
            _ctx.getClient(), playerId, createLoggingConfirmListener("getUserCookie"));
    }

    //---- .game -----------------------------------------------------------

    protected function sendChat_v1 (msg :String) :void
    {
        validateConnected();
        validateChat(msg);
        // Post a message to the game object, the controller will listen and call localChat().
        _gameObj.postMessage(WhirledGameObject.GAME_CHAT, [ msg ]);
    }

    protected function getLevelPacks_v1 () :Array
    {
        var packs :Array = [];
        for each (var data :GameData in _gameObj.gameData) {
            if (data.getType() != GameData.LEVEL_DATA) {
                continue;
            }
            // if the level pack is premium, only add it if we own it
            if ((data as LevelData).premium && !playerOwnsData(data.getType(), data.ident)) {
                continue;
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
        for each (var data :GameData in _gameObj.gameData) {
            if (data.getType() != GameData.ITEM_DATA) {
                continue;
            }
            packs.unshift({ ident: data.ident,
                            name: data.name,
                            mediaURL: data.mediaURL });
        }
        return packs;
    }

    protected function getOccupants_v1 () :Array
    {
        validateConnected();
        var occs :Array = [];
        for each (var occInfo :OccupantInfo in _gameObj.occupantInfo.toArray()) {
            if (isInited(occInfo)) {
                occs.push(occInfo.bodyOid);
            }
        }
        return occs;
    }

    protected function getOccupantName_v1 (playerId :int) :String
    {
        validateConnected();
        var occInfo :OccupantInfo = (_gameObj.occupantInfo.get(playerId) as OccupantInfo);
        return isInited(occInfo) ? occInfo.username.toString() : null;
    }

    protected function getControllerId_v1 () :int
    {
        validateConnected();
        return _gameObj.controllerOid;
    }

    protected function getTurnHolder_v1 () :int
    {
        validateConnected();
        var occInfo :OccupantInfo = _gameObj.getOccupantInfo(_gameObj.turnHolder);
        return isInited(occInfo) ? occInfo.bodyOid : 0;
    }

    protected function getRound_v1 () :int
    {
        validateConnected();
        return _gameObj.roundId;
    }

    protected function isInPlay_v1 () :Boolean
    {
        validateConnected();
        return _gameObj.isInPlay();
    }

    protected function startNextTurn_v1 (nextPlayerId :int) :void
    {
        validateConnected();
        _gameObj.whirledGameService.endTurn(
            _ctx.getClient(), nextPlayerId, createLoggingConfirmListener("endTurn"));
    }

    protected function endRound_v1 (nextRoundDelay :int) :void
    {
        validateConnected();
        _gameObj.whirledGameService.endRound(
            _ctx.getClient(), nextRoundDelay, createLoggingConfirmListener("endRound"));
    }

//    protected function endGame_v2 (... winnerIds) :void
//    {
//        validateConnected();
//        _gameObj.whirledGameService.endGame(
//            _ctx.getClient(), toTypedIntArray(winnerIds), createLoggingConfirmListener("endGame"));
//    }

    protected function endGame_v2 (... winnerIds) :void
    {
        validateConnected();

        // if this is a table game, all the non-winners are losers, if it's not a table game then
        // no one is a loser because we're not going to declare that all watchers automatically be
        // considered as players and thus contribute to the winners' booty
        var loserIds :Array = [];
        // party games have a zero length players array
        for (var ii :int = 0; ii < _gameObj.players.length; ii++) {
            var occInfo :OccupantInfo = _gameObj.getOccupantInfo(_gameObj.players[ii] as Name);
            if (isInited(occInfo)) {
                loserIds.push(occInfo.bodyOid);
            }
        }
        endGameWithWinners_v1(winnerIds, loserIds, 0) // WhirledGameControl.CASCADING_PAYOUT
    }

    protected function endGameWithWinners_v1 (
        winnerIds :Array, loserIds :Array, payoutType :int) :void
    {
        validateConnected();

        // pass the buck straight on through, the server will validate everything
        _gameObj.whirledGameService.endGameWithWinners(
            _ctx.getClient(), toTypedIntArray(winnerIds), toTypedIntArray(loserIds), payoutType,
            createLoggingConfirmListener("endGameWithWinners"));
    }

    protected function endGameWithScores_v1 (playerIds :Array, scores :Array /* of int */,
        payoutType :int) :void
    {
        validateConnected();

        // pass the buck straight on through, the server will validate everything
        _gameObj.whirledGameService.endGameWithScores(
            _ctx.getClient(), toTypedIntArray(playerIds), toTypedIntArray(scores), payoutType,
            createLoggingConfirmListener("endGameWithWinners"));
    }

    protected function restartGameIn_v1 (seconds :int) :void
    {
        validateConnected();
        _gameObj.whirledGameService.restartGameIn(
            _ctx.getClient(), seconds, createLoggingConfirmListener("restartGameIn"));
    }

    protected function getMyId_v1 () :int
    {
        // Note: this is overridden in the thane backend
        validateConnected();
        return _ctx.getClient().getClientObject().getOid();
    }

    //---- .game.seating ---------------------------------------------------

    protected function getPlayerPosition_v1 (playerId :int) :int
    {
        validateConnected();
        var occInfo :OccupantInfo = (_gameObj.occupantInfo.get(playerId) as OccupantInfo);
        if (!isInited(occInfo)) {
            return -1;
        }
        return _gameObj.getPlayerIndex(occInfo.username);
    }

    protected function getPlayers_v1 () :Array
    {
        validateConnected();
        var playerIds :Array = [];
        for (var ii :int = 0; ii < _gameObj.players.length; ii++) {
            var occInfo :OccupantInfo = _gameObj.getOccupantInfo(_gameObj.players[ii] as Name);
            playerIds.push(isInited(occInfo) ? occInfo.bodyOid : 0);
        }
        return playerIds;
    }

    //---- .services -------------------------------------------------------

    protected function setTicker_v1 (tickerName :String, msOfDelay :int) :void
    {
        validateConnected();
        validateName(tickerName);
        _gameObj.whirledGameService.setTicker(
            _ctx.getClient(), tickerName, msOfDelay, createLoggingConfirmListener("setTicker"));
    }

    protected function getDictionaryLetterSet_v2 (
        locale :String, dictionary :String, count :int, callback :Function) :void
    {
        validateConnected();
        var listener :InvocationService_ResultListener;
        if (callback != null) {
            var failure :Function = function (cause :String = null) :void {
                // ignore the cause, return an empty array
                callback ([]);
            }
            var success :Function = function (result :String = null) :void {
                // splice the resulting string, and return as array
                var r : Array = result.split(",");
                callback (r);
            };
            listener = new ResultWrapper(failure, success);
        } else {
            listener = createLoggingResultListener("checkDictionaryWord");
        }

        // just relay the data over to the server
        _gameObj.whirledGameService.getDictionaryLetterSet(
            _ctx.getClient(), locale, dictionary, count, listener);
    }

    protected function checkDictionaryWord_v2 (
        locale :String, dictionary :String, word :String, callback :Function) :void
    {
        validateConnected();
        var listener :InvocationService_ResultListener;
        if (callback != null) {
            var failure :Function = function (cause :String = null) :void {
                // ignore the cause, return failure
                callback (word, false);
            }
            var success :Function = function (result :Object = null) :void {
                // server returns a boolean, so convert it and send it over
                var r : Boolean = Boolean(result);
                callback (word, r);
            };
            listener = new ResultWrapper(failure, success);
        } else {
            listener = createLoggingResultListener("checkDictionaryWord");
        }

        // just relay the data over to the server
        _gameObj.whirledGameService.checkDictionaryWord(
            _ctx.getClient(), locale, dictionary, word, listener);
    }

    //---- .services.bags --------------------------------------------------

    protected function mergeCollection_v1 (srcColl :String, intoColl :String) :void
    {
        validateConnected();
        validateName(srcColl);
        validateName(intoColl);
        _gameObj.whirledGameService.mergeCollection(_ctx.getClient(),
            srcColl, intoColl, createLoggingConfirmListener("mergeCollection"));
    }

    /**
     * Helper method for setCollection and addToCollection.
     */
    protected function populateCollection_v1 (
        collName :String, values :Array, clearExisting :Boolean) :void
    {
        validateConnected();
        validateName(collName);
        if (values == null) {
            throw new ArgumentError("Collection values may not be null.");
        }
        validateValue(values);

        var encodedValues :TypedArray = (ObjectMarshaller.encode(values, true) as TypedArray);
        _gameObj.whirledGameService.addToCollection(
            _ctx.getClient(), collName, encodedValues, clearExisting,
            createLoggingConfirmListener("populateCollection"));
    }

    /**
     * Helper method for pickFromCollection and dealFromCollection.
     */
    protected function getFromCollection_v2 (
        collName :String, count :int, msgOrPropName :String, playerId :int,
        consume :Boolean, callback :Function) :void
    {
        validateConnected();
        validateName(collName);
        validateName(msgOrPropName);
        if (count < 1) {
            throw new ArgumentError("Must retrieve at least one element!");
        }

        var listener :InvocationService_ConfirmListener;
        if (callback != null) {
            // TODO: Figure out the method sig of the callback, and what it means
            var fn :Function = function (cause :String = null) :void {
                if (cause == null) {
                    callback(count);
                } else {
                    callback(parseInt(cause));
                }
            };
            listener = new ConfirmAdapter(fn, fn);

        } else {
            listener = createLoggingConfirmListener("getFromCollection");
        }

        _gameObj.whirledGameService.getFromCollection(
            _ctx.getClient(), collName, consume, count, msgOrPropName, playerId, listener);
    }

    //---- backwards compatability -----------------------------------------

    protected function getDictionaryLetterSet_v1 (
        locale :String, count :int, callback :Function) :void
    {
        getDictionaryLetterSet_v2(locale, null, count, callback);
    }

    protected function checkDictionaryWord_v1 (
        locale :String, word :String, callback :Function) :void
    {
        checkDictionaryWord_v2(locale, null, word, callback);
    }

    /** A backwards compatible method. */
    protected function getAvailableFlow_v1 () :int
    {
        return 0;
    }

    /** A backwards compatible method. */
    protected function awardFlow_v1 (amount :int) :void
    {
        // NOOP!
    }

    /** A backwards compatible method. */
    protected function awardFlow_v2 (perf :int) :int
    {
        return 0;
    }

    /** 
     * A backwards compatible method.
     *
     * Note: immediate defaults to true, even though immediate=false is the general case. We are
     * providing some backwards compatibility to old versions of setProperty_v1() that assumed
     * immediate and did not pass a 4th value.  All callers should now specify that value
     * explicitly.
     * (And of course, setProperty_v2 takes control of this situation.)
     */
    protected function setProperty_v1 (
        propName :String, value :Object, index :int, immediate :Boolean = true) :void
    {
        // very naughty hack to support old setProperty semantics for auto-sizing arrays,
        // since Defense relies on them. TODO: robert, remove after your game is fixed up!
        if (value is Array && value.length == 0 && provideArrayCompatibility()) {
            value.length = 1000; 
        }
        
        var key :Object = (index < 0) ? null : index;
        var isArray :Boolean = (key != null);
        setProperty_v2(propName, value, key, isArray, immediate);
    }

    // --------------------------

    /**
     * Converts a Flash array of ints to a TypedArray for delivery over the wire to the server.
     */
    protected function toTypedIntArray (array :Array) :TypedArray
    {
        var tarray :TypedArray = TypedArray.create(int);
        tarray.addAll(array);
        return tarray;
    }

    protected function playerOwnsData (type :int, ident :String) :Boolean
    {
        return false; // this information is provided by the containing system
    }

    // TEMP TODO REMOVE XXX
    protected function provideArrayCompatibility () :Boolean
    {
        var cfg :BaseGameConfig = getConfig();
        var url :String = cfg.getGameDefinition().getMediaPath(cfg.getGameId());

        // Tree house defense
        return (url === "http://media.whirled.com/6c7fa832bd422899ffea685adadbf55c184edb2e.swf");
    }

    protected var _ctx :PresentsContext;

    protected var _userListener :MessageAdapter = new MessageAdapter(messageReceivedOnUserObject);

    protected var _gameObj :WhirledGameObject;

    protected var _userFuncs :Object;

    protected var _gameData :Object;

    /** playerIndex -> callback functions waiting for the cookie. */
    protected var _cookieCallbacks :Dictionary;

    protected static const MAX_USER_COOKIE :int = 4096;
}
}

