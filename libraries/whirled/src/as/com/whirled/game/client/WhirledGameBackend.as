package com.whirled.game.client {

import flash.display.DisplayObject;
import flash.display.StageQuality;
import flash.events.KeyboardEvent;
import flash.geom.Rectangle;
import flash.geom.Point;

import com.threerings.util.MessageBundle;
import com.threerings.util.Name;

import com.threerings.presents.dobj.MessageEvent;

import com.threerings.crowd.data.BodyObject;
import com.threerings.crowd.util.CrowdContext;

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
        super(ctx, gameObj, ctrl);
    }

    public function setContainer (container :GameContainer) :void
    {
        _container = container;
    }

    // from BaseGameBackend
    override public function shutdown () :void
    {
        super.shutdown();

        // once the usercode is incapable of calling setFrameRate, ensure they're reset to defaults
        _container.stage.frameRate = 30;
        _container.stage.quality = StageQuality.MEDIUM;
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
            // we still use old name for the dispatch method, and we must use
            // the coercive cast to Boolean instead of using "as", because older versions
            // of the SDK will not return any value, so we must turn those into false.
            var cancelled :Boolean = Boolean(callUserCode("flowAwarded_v1", amount, percentile));
            if (!cancelled) {
                // if the usercode has not indicated that it will handle the event themselves,
                // we need to do it.
                _ctx.getChatDirector().displayInfo(WhirledGameCodes.WHIRLEDGAME_MESSAGE_BUNDLE,
                    MessageBundle.tcompose("m.coins_awarded", amount));
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

        // .game
        o["getMyId_v1"] = getMyId_v1;
        o["isMyTurn_v1"] = isMyTurn_v1;
        o["playerReady_v1"] = playerReady_v1;

        // .game.seating
        o["getMyPosition_v1"] = getMyPosition_v1;

        // Old methods: backwards compatability
        o["getStageBounds_v1"] = getStageBounds_v1;
        o["getHeadShot_v1"] = getHeadShot_v1;
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
        // TODO: make this look distinct from other system chat
        _ctx.getChatDirector().displayInfo(null, MessageBundle.taint(msg));
    }

    protected function filter_v1 (text :String) :String
    {
        return _ctx.getChatDirector().filter(text, null, true);
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

    protected function setFrameRate_v1 (frameRate :Number, quality :String) :void
    {
        validateConnected(); // so that the game can't futz the frame rate after we disconnect it!

        // then, let these throw whatever errors they might. Not our problem.
        _container.stage.frameRate = Math.max(frameRate, 15);
        _container.stage.quality = quality;
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
        _ctrl.playerIsReady();
    }

    protected function getMyId_v1 () :int
    {
        validateConnected();
        return _ctx.getClient().getClientObject().getOid();
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

    protected var _container :GameContainer;

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
