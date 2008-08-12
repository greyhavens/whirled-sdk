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
    }

    /** @private */
    override protected function createSubControls () :Array
    {
        return [
            _game = new GameServerSubControl(this),
        ];
    }

    /** @private */
    protected var _game :GameServerSubControl;

    protected var _roomControls :Dictionary = new Dictionary();

    protected var _playerControls :Dictionary = new Dictionary();
}
}

