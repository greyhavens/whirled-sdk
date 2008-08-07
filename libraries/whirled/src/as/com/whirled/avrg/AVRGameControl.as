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
public class AVRGameControl extends AbstractControl
{
    /**
     * Create a world game interface. The display object is your world game.
     */
    public function AVRGameControl (disp :DisplayObject)
    {
        super(disp);

        // set up the default hitPointTester
        _client.setHitPointTester(disp.root.hitTestPoint);
    }

    public function get game () :GameSubControl
    {
        return _game;
    }

    public function get room () :RoomSubControl
    {
        return _room;
    }

    public function get player () :PlayerSubControl
    {
        return _player;
    }

    /**
     * Get the ClientSubControl which contains methods that are only relevant on the
     * client, as they deal with e.g. on-screen pixels rather than logical positioning.
     */
    public function get client () :ClientSubControl
    {
        return _client;
    }

    // TODO: Move to server
    public function deactivateGame () :Boolean
    {
        return callHostCode("deactivateGame_v1");
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
            _game = new GameSubControl(this),
            _room = new RoomSubControl(this),
            _player = new PlayerSubControl(this),
            _client = new ClientSubControl(this),
        ];
    }

    /** @private */
    protected var _game :GameSubControl;
    /** @private */
    protected var _room :RoomSubControl;
    /** @private */
    protected var _player :PlayerSubControl;
    /** @private */
    protected var _client :ClientSubControl;
}
}

