//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg {

import flash.display.DisplayObject;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

import com.threerings.util.Log;

import com.whirled.AbstractControl;
import com.whirled.AbstractSubControl;
import com.whirled.ServerObject;
import com.whirled.net.PropertySubControl;
import com.whirled.net.impl.PropertyGetSubControlImpl;
import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.avrg.PlayerBaseSubControl;
import com.whirled.avrg.RoomBaseSubControl;

/**
 * This file should be included by AVR games so that they can communicate
 * with the whirled.
 *
 * AVRGame means: Alternate Virtual Reality Game, and refers to games
 * played within the whirled environment with your avatar.
 *
 * <p><b>Note</b>: The AVRG framework is "alpha" and may be changed in incompatible ways.
 * If you are making an AVRG game, please let us know what you're doing in the AVRG
 * discussion forum: <a href="http://first.whirled.com/#whirleds-d_135_r">http://first.whirled.com/#whirleds-d_135_r</a></p>
 */
public class AVRServerGameControl extends AbstractControl
{
    /**
     * Create a world game interface. The display object is your world game.
     */
    public function AVRServerGameControl (serv :ServerObject)
    {
        super(serv);
    }

    public function get game () :GameServerSubControl
    {
        return _game;
    }

    public function getRoom (roomId :int) :RoomServerSubControl
    {
        var ctrl :RoomServerSubControl = _roomControls[roomId];
        if (ctrl == null) {
            // This throws an error if the room isn't loaded
            // TODO: document
            ctrl = new RoomServerSubControl(this, roomId);
            ctrl.gotHostPropsFriend(_funcs);
            _roomControls[roomId] = ctrl;
        }
        return ctrl;
    }

    public function getPlayer (playerId :int) :PlayerServerSubControl
    {
        var ctrl :PlayerServerSubControl = _playerControls[playerId];
        if (ctrl == null) {
            // This throws an error if the room isn't loaded
            // TODO: document
            ctrl = new PlayerServerSubControl(this, playerId);
            ctrl.gotHostPropsFriend(_funcs);
            _playerControls[playerId] = ctrl;
        }
        return ctrl;
    }

    /** @private */
    override protected function setUserProps (o :Object) :void
    {
        super.setUserProps(o);

        o["playerLeft_v1"] = relayTo(getRoom, "playerLeft_v1");
        o["playerEntered_v1"] = relayTo(getRoom, "playerEntered_v1");
        o["actorStateSet_v1"] = relayTo(getRoom, "actorStateSet_v1");
        o["actorAppearanceChanged_v1"] = relayTo(getRoom, "actorAppearanceChanged_v1");
        o["playerMoved_v1"] = relayTo(getRoom, "playerMoved_v1");

        o["mobSpawned_v1"] = relayTo(getRoom, "mobSpawned_v1");
        o["mobRemoved_v1"] = relayTo(getRoom, "mobRemoved_v1");
        o["mobAppearanceChanged_v1"] = relayTo(getRoom, "mobAppearanceChanged_v1");

        o["leftRoom_v1"] = relayTo(getPlayer, "leftRoom_v1");
        o["enteredRoom_v1"] = relayTo(getPlayer, "enteredRoom_v1");
        o["taskCompleted_v1"] = relayTo(getPlayer, "taskCompleted");
        o["player_propertyWasSet_v1"] = relayTo(getPlayerProps, "propertyWasSet_v1");

        o["roomUnloaded_v1"] = roomUnloaded_v1;

        o["playerJoinedGame_v1"] = playerJoinedGame_v1;
        o["playerLeftGame_v1"] = playerLeftGame_v1;
    }

    /** @private */
    override protected function createSubControls () :Array
    {
        return [
            _game = new GameServerSubControl(this),
        ];
    }

    /** @private */
    protected function getPlayerProps (playerId :int) :PropertySubControl
    {
        return getPlayer(playerId).props;
    }

    /** @private */
    protected function playerJoinedGame_v1 (playerId :int) :void
    {
        game.dispatchFriend(new AVRGameControlEvent(
            AVRGameControlEvent.PLAYER_JOINED_GAME, null, playerId));
    }

    /** @private */
    protected function playerLeftGame_v1 (playerId :int) :void
    {
        game.dispatchFriend(new AVRGameControlEvent(
            AVRGameControlEvent.PLAYER_QUIT_GAME, null, playerId));
        delete _playerControls[playerId];
    }

    /** @private */
    protected function relayTo (getObj :Function, fun :String) :Function
    {
        return function (targetId :int, ... args) :* {
            // fetch the relevant subcontrol
            var obj :Object = getObj(targetId);
            // early-development sanity checks
            if (obj == null) {
                throw new Error("failed to find subcontrol [targetId=" + targetId + "]");
            }
            if (obj[fun] == null) {
                throw new Error("failed to find function in subcontrol [targetId=" +
                                targetId + ", fun=" + fun + "]");
            }
            // call the right function on it
            return obj[fun].apply(obj, args);
        };
    }

    /**
     * Called by the backend when a room is no longer accessible.
     */
    protected function roomUnloaded_v1 (roomId :int) :void
    {
        delete _roomControls[roomId];
    }

    /** @private */
    protected var _game :GameServerSubControl;

    /** @private */
    protected var _roomControls :Dictionary = new Dictionary();

    /** @private */
    protected var _playerControls :Dictionary = new Dictionary();
}
}

