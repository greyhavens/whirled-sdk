//
// $Id$

package com.whirled.game.loopback {

import com.threerings.util.Log;
import com.threerings.util.ObjectMarshaller;
import com.threerings.util.StringUtil;
import com.whirled.ServerObject;
import com.whirled.game.GameControl;

import flash.display.DisplayObject;
import flash.events.Event;

public class LoopbackGameControl extends GameControl
{
    public function LoopbackGameControl (disp :DisplayObject, autoReady :Boolean = true)
    {
        if (disp is ServerObject) {
            _serverLoopback = this;
            _myId = SERVER_AGENT_ID;
        } else {
            _playerLoopback = this;
            _myId = PLAYER_ID;
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
        //o["gameData"] = _gameData;

        // convert our game config from a HashMap to a Dictionary
        /*var gameConfig :Object = {};
        var cfg :BaseGameConfig = getConfig();
        cfg.params.forEach(function (key :Object, value :Object) :void {
            gameConfig[key] = (value is Boxed) ? Boxed(value).unbox() : value;
        });
        o["gameConfig"] = gameConfig;
        o["gameInfo"] = createGameInfo();*/

        // GameControl
        //o["commitTransaction"] = commitTransaction_v1;
        //o["startTransaction"] = startTransaction_v1;

        // .net
        o["sendMessage_v2"] = sendMessage_v2;
        //o["setProperty_v2"] = setProperty_v2;
        //o["testAndSetProperty_v1"] = testAndSetProperty_v1;

        // .player
        //o["getUserCookie_v2"] = getUserCookie_v2;
        //o["getCookie_v1"] = getCookie_v1;
        //o["setUserCookie_v1"] = setUserCookie_v1;
        //o["setCookie_v1"] = setCookie_v1;
        //o["holdsTrophy_v1"] = holdsTrophy_v1;
        //o["awardTrophy_v1"] = awardTrophy_v1;
        //o["awardPrize_v1"] = awardPrize_v1;
        //o["getPlayerItemPacks_v1"] = getPlayerItemPacks_v1;
        //o["getPlayerLevelPacks_v1"] = getPlayerLevelPacks_v1;

        // .game
        //o["endGame_v2"] = endGame_v2;
        //o["endGameWithScores_v1"] = endGameWithScores_v1;
        //o["endGameWithWinners_v1"] = endGameWithWinners_v1;
        //o["endRound_v1"] = endRound_v1;
        //o["getControllerId_v1"] = getControllerId_v1;
        //o["getLevelPacks_v2"] = getLevelPacks_v2;
        //o["getItemPacks_v1"] = getItemPacks_v1;
        //o["loadLevelPackData_v1"] = loadLevelPackData_v1;
        //o["loadItemPackData_v1"] = loadItemPackData_v1;
        //o["getOccupants_v1"] = getOccupants_v1;
        //o["getOccupantName_v1"] = getOccupantName_v1;
        //o["getRound_v1"] = getRound_v1;
        //o["getTurnHolder_v1"] = getTurnHolder_v1;
        //o["isInPlay_v1"] = isInPlay_v1;
        //o["restartGameIn_v1"] = restartGameIn_v1;
        //o["sendChat_v1"] = sendChat_v1;
        //o["startNextTurn_v1"] = startNextTurn_v1;
        //o["getMyId_v1"] = getMyId_v1;

        // .game.seating
        //o["getPlayers_v1"] = getPlayers_v1;
        //o["getPlayerPosition_v1"] = getPlayerPosition_v1;
        //o["getMyPosition_v1"] = getMyPosition_v1;

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

    protected function sendMessage_v2 (messageName :String, value :Object, playerId :int) :void
    {
        validateName(messageName);
        validateValue(value);

        if ((playerId == TO_ALL || playerId == PLAYER_ID) && _playerLoopback != null) {
            _playerLoopback.callUserCode("messageReceived_v2", messageName, value, _myId);
        }

        if ((playerId == TO_ALL || playerId == SERVER_AGENT_ID) && _serverLoopback != null) {
            _serverLoopback.callUserCode("messageReceived_v2", messageName, value, _myId);
        }
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

    protected var _myId :int;
    protected var _userFuncs :Object;

    protected var log :Log = Log.getLog(this);

    protected static var _playerLoopback :LoopbackGameControl;
    protected static var _serverLoopback :LoopbackGameControl;

    protected static const PLAYER_ID :int = 1
    protected static const SERVER_AGENT_ID :int = int.MIN_VALUE;
    protected static const TO_ALL :int = 0;
}

}
