//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg.server {

import flash.display.DisplayObject;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

import com.threerings.util.Log;

import com.whirled.AbstractControl;
import com.whirled.ServerObject;
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
            ctrl = _roomControls[roomId] = new RoomServerSubControl(this, roomId);
        }
        return ctrl;
    }

    public function getPlayer (playerId :int) :PlayerServerSubControl
    {
        var ctrl :PlayerServerSubControl = _playerControls[playerId];
        if (ctrl == null) {
            ctrl = _playerControls[playerId] = new PlayerServerSubControl(this, playerId);
        }
        return ctrl;
    }

    /** @private */
    override protected function setUserProps (o :Object) :void
    {
        super.setUserProps(o);

        o["playerLeft_v1"] =
            relayToRoom(RoomBaseSubControl.prototype.playerLeft_v1);
        o["playerEntered_v1"] =
            relayToRoom(RoomBaseSubControl.prototype.playerEntered_v1);

        o["actorStateSet_v1"] =
            relayToRoom(RoomBaseSubControl.prototype.actorStateSet_v1);
        o["actorAppearanceChanged_v1"] =
            relayToRoom(RoomBaseSubControl.prototype.actorAppearanceChanged_v1);

// TODO: not sure how mobs on the server are going to work quite yet
//         o["mobRemoved_v1"] =
//             relayToRoom(RoomBaseSubControl.prototype.mobRemoved_v1);
//         o["mobAppearanceChanged_v1"] =
//             relayToRoom(RoomBaseSubControl.mobAppearanceChanged_v1);

        o["room_messageReceived_v1"] =
            relayToRoom(RoomBaseSubControl.prototype.messageReceived);

        o["leftRoom_v1"] =
            relayToRoom(PlayerBaseSubControl.prototype.leftRoom_v1);
        o["enteredRoom_v1"] =
            relayToRoom(PlayerBaseSubControl.prototype.enteredRoom_v1);
        o["player_messageReceived_v1"] =
            relayToPlayer(PlayerBaseSubControl.prototype.messageReceived);
        o["coinsAwarded_v1"] =
            relayToPlayer(PlayerBaseSubControl.prototype.coinsAwarded);
    }

    /** @private */
    override protected function createSubControls () :Array
    {
        return [
            _game = new GameServerSubControl(this),
        ];
    }

    /** @private */
    protected function relayToRoom (fun :Function) :Function
    {
        return function (targetId :int, ... args) :* {
            return fun.apply(getRoom(targetId), args);
        };
    }

    /** @private */
    protected function relayToPlayer (fun :Function) :Function
    {
        return function (targetId :int, ... args) :* {
            return fun.apply(getPlayer(targetId), args);
        };
    }

    /** @private */
    protected var _game :GameServerSubControl;

    /** @private */
    protected var _roomControls :Dictionary = new Dictionary();

    /** @private */
    protected var _playerControls :Dictionary = new Dictionary();
}
}

