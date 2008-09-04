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
public class AVRGameControl extends AbstractControl
{
    /**
     * Create a world game interface. The display object is your world game.
     */
    public function AVRGameControl (disp :DisplayObject)
    {
        super(disp);

        if (disp is ServerObject) {
            throw new Error("AVRGameControl should not be instantiated with a ServerObject");
        }

        // set up the default hitPointTester
        _local.setHitPointTester(disp.root.hitTestPoint);
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
     * Get the LocalSubControl which contains methods that are only relevant on the
     * client, as they deal with e.g. on-screen pixels rather than logical positioning.
     */
    public function get local () :LocalSubControl
    {
        return _local;
    }

    public function get agent () :AgentSubControl
    {
        return _agent;
    }

    /** @private */
    override protected function setUserProps (o :Object) :void
    {
        super.setUserProps(o);

        o["requestMobSprite_v1"] = requestMobSprite_v1;

        o["leftRoom_v1"] = leftRoom_v1;
        o["enteredRoom_v1"] = enteredRoom_v1;
    }

    /** @private */
    override protected function createSubControls () :Array
    {
        return [
            _game = new GameSubControl(this),
            _room = new RoomSubControl(this),
            _player = new PlayerSubControl(this),
            _local = new LocalSubControl(this),
            _agent = new AgentSubControl(this),
        ];
    }

    /** @private */
    protected function requestMobSprite_v1 (id :String) :DisplayObject
    {
        var ctrl :MobSubControl = MobSubControl(_room.getMobSubControl(id));
        if (ctrl != null) {
            // TODO: this is not actually OK, the control should be nuked when we move
            return ctrl.getMobSprite();
        }
        if (_local.mobSpriteExporter == null) {
            Log.getLog(this).warning(
                "Sprite requested but control has no exporter [id=" + id + "]");
            return null;
        }
        var sprite :DisplayObject = _local.mobSpriteExporter(id) as DisplayObject;
        Log.getLog(this).debug("Requested sprite [id=" + id + ", sprite=" + sprite + "]");
        if (sprite != null) {
            var delayEvent :Boolean = false;
            _room.setMobSubControl(id, new MobSubControl(this, id, sprite), delayEvent);
        }
        return sprite;
    }

    internal function leftRoom_v1 (scene :int) :void    
    {
        _player.leftRoom_v1(scene);
        _room.leftRoom();
    }

    internal function enteredRoom_v1 (scene :int) :void    
    {
        _player.enteredRoom_v1(scene);
    }

    /** @private */
    protected var _game :GameSubControl;
    /** @private */
    protected var _room :RoomSubControl;
    /** @private */
    protected var _player :PlayerSubControl;
    /** @private */
    protected var _local :LocalSubControl;
    /** @private */
    protected var _agent :AgentSubControl;
}
}

import flash.display.DisplayObject;

import com.whirled.avrg.MobSubControl;

class MobEntry
{
    public var control :MobSubControl;

    public function MobEntry (control :MobSubControl, sprite :DisplayObject)
    {
        this.control = control;
    }
}
