package com.whirled.game.client {

import flash.display.DisplayObject;
import flash.display.Stage;
import flash.display.StageQuality;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.utils.ByteArray;

import com.threerings.util.MessageBundle;
import com.threerings.util.Name;

import com.threerings.presents.dobj.MessageEvent;

import com.threerings.crowd.data.BodyObject;
import com.threerings.crowd.util.CrowdContext;

import com.whirled.game.data.BaseGameConfig;
import com.whirled.game.data.WhirledGameCodes;
import com.whirled.game.data.WhirledGameObject;

/**
 * Manages the backend of the game on a flash client.
 */
public class WhirledGameBackend extends BaseGameBackend
{
    public function WhirledGameBackend (
        ctx :CrowdContext, gameObj :WhirledGameObject, ctrl :WhirledGameController)
    {
        super(ctx, gameObj);
        _ctrl = ctrl;
        
        (_ctx as CrowdContext).getChatDirector().addChatDisplay(this);
    }

    public function setContainer (container :GameContainer) :void
    {
        _container = container;
        _stage = container.stage;
        if (_stage == null) {
            _container.addEventListener(Event.ADDED_TO_STAGE, handleGrabStage);
        }
    }

    // from BaseGameBackend
    override public function shutdown () :void
    {
        super.shutdown();

        (_ctx as CrowdContext).getChatDirector().removeChatDisplay(this);

        // once the usercode is incapable of calling setFrameRate and setStageQuality
        // ensure they're reset to defaults
        _stage.frameRate = 30;
        _stage.quality = StageQuality.MEDIUM;
    }

    /**
     * Convenience function to get our name.
     */
    public function getUsername () :Name
    {
        var body :BodyObject = (_ctx.getClient().getClientObject() as BodyObject);
        return body.getVisibleName();
    }

    /**
     * Called by the WhirledGamePanel when the size of the game area has changed.
     */
    public function sizeChanged () :void
    {
        callUserCode("sizeChanged_v1", getSize_v1());
    }

    /** @inheritDoc */
    // from BaseGameBackend
    override public function messageReceived (event :MessageEvent) :void
    {
        var name :String = event.getName();
        if (WhirledGameObject.GAME_CHAT == name) {
            // chat sent by the game, route to our displayInfo
            localChat_v1(String(event.getArgs()[0]));

        } else {
            super.messageReceived(event);
        }
    }

    /** @inheritDoc */
    // from BaseGameBackend
    override protected function notifyControllerUserCodeIsConnected (autoReady :Boolean) :void
    {
        _ctrl.userCodeIsConnected(autoReady);
    }

    /** @inheritDoc */
    // from BaseGameBackend
    override protected function getConfig () :BaseGameConfig
    {
        return _ctrl.getPlaceConfig() as BaseGameConfig;
    }

    /**
     * Displays an info message to the player. Default does nothing, so subclasses should 
     * override.
     */
    protected function displayInfo (bundle :String, msg :String, localType :String = null) :void
    {
        (_ctx as CrowdContext).getChatDirector().displayInfo(bundle, msg, localType);
    }

    /**
     * Displays a feedback message to the player. Default does nothing, so subclasses should 
     * override.
     */
    protected function displayFeedback (bundle :String, msg :String) :void
    {
        (_ctx as CrowdContext).getChatDirector().displayFeedback(bundle, msg);
    }

    protected function handleGrabStage (event :Event) :void
    {
        var target :DisplayObject = event.currentTarget as DisplayObject;
        target.removeEventListener(Event.ADDED_TO_STAGE, handleGrabStage);
        _stage = target.stage;
    }

    /**
     * Handle key events on our container and pass them into the game.
     */
    protected function handleKeyEvent (evt :KeyboardEvent) :void
    {
        // dispatch a cloned copy of the event, so that it's safe
        _keyDispatcher(evt.clone());
    }

    // from BaseGameBackend
    override protected function messageReceivedOnUserObject (event :MessageEvent) :void
    {
        var name :String = event.getName();
        if (name == WhirledGameObject.COINS_AWARDED_MESSAGE) {
            var amount :int = int(event.getArgs()[0]);
            var percentile :int = int(event.getArgs()[1]);
            // We still use the old name for the dispatch method. Changing it would mean
            // testing to see if we need to use the new method or the old method and this is
            // all internal anyway, so I don't care.
            // Also: we coerce the result to a Boolean because pre-2008-05-29 classes will
            // return undefined and we want that to become false.
            var cancelled :Boolean = Boolean(callUserCode("flowAwarded_v1", amount, percentile));
            if (!cancelled) {
                // If the usercode has not indicated that it will handle notification, we do it.
                reportCoinsAwarded(amount);
            }

        } else {
            super.messageReceivedOnUserObject(event);
        }
    }

    // from BaseGameBackend
    override protected function setUserCodeProperties (o :Object) :void
    {
        super.setUserCodeProperties(o);

        // here we would handle adapting old functions to a new version
        _keyDispatcher = (o["dispatchEvent_v1"] as Function);
    }

    // from BaseGameBackend
    override protected function populateProperties (o :Object) :void
    {
        super.populateProperties(o);

        // GameControl
        o["focusContainer_v1"] = focusContainer_v1;

        // .local
        o["alterKeyEvents_v1"] = alterKeyEvents_v1;
        o["backToWhirled_v1"] = backToWhirled_v1;
        o["clearScores_v1"] = clearScores_v1;
        o["filter_v1"] = filter_v1;
        o["getHeadShot_v2"] = getHeadShot_v2;
        o["getSize_v1"] = getSize_v1;
        o["localChat_v1"] = localChat_v1;
        o["setMappedScores_v1"] = setMappedScores_v1;
        o["setOccupantsLabel_v1"] = setOccupantsLabel_v1;
        o["setPlayerScores_v1"] = setPlayerScores_v1;
        o["setShowButtons_v1"] = setShowButtons_v1;
        o["setFrameRate_v1"] = setFrameRate_v1;
        o["setStageQuality_v1"] = setStageQuality_v1;

        // .game
        o["isMyTurn_v1"] = isMyTurn_v1;
        o["playerReady_v1"] = playerReady_v1;

        // .game.seating
        o["getMyPosition_v1"] = getMyPosition_v1;

        // Old methods: backwards compatability
        o["getStageBounds_v1"] = getStageBounds_v1;
        o["getHeadShot_v1"] = getHeadShot_v1;
    }

    /**
     * We've already tried notifying usercode, now do a framework-level notification
     * of the coin awarding.
     */
    protected function reportCoinsAwarded (amount :int) :void
    {
        displayInfo(WhirledGameCodes.WHIRLEDGAME_MESSAGE_BUNDLE,
            MessageBundle.tcompose("m.coins_awarded", amount));
    }

    //---- GameControl -----------------------------------------------------

    protected function focusContainer_v1 () :void
    {
        validateConnected();
        _container.setFocus();
    }

    //---- .local ----------------------------------------------------------

    protected function alterKeyEvents_v1 (keyEventType :String, add :Boolean) :void
    {
        validateConnected();
        if (add) {
            _container.addEventListener(keyEventType, handleKeyEvent);
        } else {
            _container.removeEventListener(keyEventType, handleKeyEvent);
        }
    }

    protected function backToWhirled_v1 (showLobby :Boolean = false) :void
    {
        _ctrl.backToWhirled(showLobby);
    }

    protected function localChat_v1 (msg :String) :void
    {
        validateChat(msg);
        // The sendChat() messages will end up being routed through this method on each client.
        displayInfo(null, MessageBundle.taint(msg), WhirledGameCodes.USERGAME_CHAT_TYPE);
    }

    protected function filter_v1 (text :String) :String
    {
        return (_ctx as CrowdContext).getChatDirector().filter(text, null, true);
    }

    /**
     * Get the size of the game area.
     */
    protected function getSize_v1 () :Point
    {
        return new Point(_container.width, _container.height);
    }

    protected function setShowButtons_v1 (rematch :Boolean, back :Boolean) :void
    {
        (_ctrl.getPlaceView() as WhirledGamePanel).setShowButtons(rematch, back, back);
    }

    protected function setFrameRate_v1 (frameRate :Number, quality :String = null) :void
    {
        validateConnected(); // so that the game can't futz the frame rate after we disconnect it!

        // then, let this throw whatever errors they might. Not our problem.
        _stage.frameRate = Math.max(frameRate, 15);

        // NOTE: originally the quality was specified as the second argument to setFrameRate.
        // To preserve backwards compatibility, the quality arg is now optional, but if specified
        // we must still let it work.
        if (quality != null) {
            setStageQuality_v1(quality);
        }
    }

    protected function setStageQuality_v1 (quality :String) :void
    {
        validateConnected(); // it's important not to let any still-running game code
        // alter the frame rate after we've "shut it off" and restored the whirled default quality

        // if quality is an invalid string, this might throw an error. Not our problem.
        _stage.quality = quality;
    }

    protected function setOccupantsLabel_v1 (label :String) :void
    {
        (_ctrl.getPlaceView() as WhirledGamePanel).getPlayerList().setLabel(label);
    }

    protected function clearScores_v1 (clearValue :Object = null,
        sortValuesToo :Boolean = false) :void
    {
        (_ctrl.getPlaceView() as WhirledGamePanel).getPlayerList().clearScores(
            clearValue, sortValuesToo);
    }

    protected function setPlayerScores_v1 (scores :Array, sortValues :Array = null) :void
    {
        (_ctrl.getPlaceView() as WhirledGamePanel).getPlayerList().setPlayerScores(
            scores, sortValues);
    }

    protected function setMappedScores_v1 (scores :Object) :void
    {
        (_ctrl.getPlaceView() as WhirledGamePanel).getPlayerList().setMappedScores(scores);
    }

    protected function getHeadShot_v2 (occupant :int) :DisplayObject
    {
        validateConnected();

        // in here, we just return a dummy value
        return new HeadSpriteShim();
    }

    //---- .game -----------------------------------------------------------

    /**
     * Called by the client code when it is ready for the game to be started (if called before the
     * game ever starts) or rematched (if called after the game has ended).
     */
    protected function playerReady_v1 () :void
    {
        if (isParty()) {
            // I'd like to throw an error, but some old games incorrectly call this
            // and we don't want to break them, so just log it here, but we throw an Error
            // in newer versions of GameSubControl.
            logGameError("playerReady() is only applicable to seated games.");
            return;
        }
        _ctrl.playerIsReady();
    }

    protected function isMyTurn_v1 () :Boolean
    {
        validateConnected();
        return getUsername().equals(_gameObj.turnHolder);
    }

    //---- .game.seating ---------------------------------------------------

    protected function getMyPosition_v1 () :int
    {
        validateConnected();
        return _gameObj.getPlayerIndex(
            (_ctx.getClient().getClientObject() as BodyObject).getVisibleName());
    }

    //---- backwards compatability -----------------------------------------

    /**
     * Backwards compatability. Added June 18, 2007, removed Oct 24, 2007. There
     * probably aren't many/any games that used this "in the wild", so we may be able to remove
     * this at some point.
     */
    protected function getStageBounds_v1 () :Rectangle
    {
        var size :Point = getSize_v1();
        return new Rectangle(0, 0, size.x, size.y);
    }

    /** 
     * A backwards compatible method.
     */
    protected function getHeadShot_v1 (occupant :int, callback :Function) :void
    {
        // this callback was defined to return a Sprite, so to preserve
        // backwards compatibility we wrap the new headshot in a sprite
        var s :HeadSpriteShim = new HeadSpriteShim();
        s.addChild(getHeadShot_v2(occupant));
        callback(s, true);
    }

    protected var _ctrl :WhirledGameController;

    protected var _container :GameContainer;

    protected var _stage :Stage;

    /** The function on the GameControl which we can use to directly dispatch events to the
     * user's game. */
    protected var _keyDispatcher :Function;
}

}

import flash.display.Sprite;

class HeadSpriteShim extends Sprite
{
    override public function get width () :Number
    {
        return 80;
    }

    override public function get height () :Number
    {
        return 60;
    }
}
