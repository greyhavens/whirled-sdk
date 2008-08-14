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
        o["mobRemoved_v1"] = mobRemoved_v1;
        o["mobAppearanceChanged_v1"] = mobAppearanceChanged_v1;
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
        var info :MobEntry = _mobs[id];
        if (info) {
            Log.getLog(this).warning(
                "Sprite requested for previously known mob [id=" + id + "]");
            return info.sprite;
        }
        if (_local.mobSpriteExporter == null) {
            Log.getLog(this).warning(
                "Sprite requested but control has no exporter [id=" + id + "]");
            return null;
        }
        var ctrl :MobControl = new MobControl(this, id);
        var sprite :DisplayObject = _local.mobSpriteExporter(id, ctrl) as DisplayObject;
        Log.getLog(this).debug("Requested sprite [id=" + id + ", sprite=" + sprite + "]");
        if (sprite) {
            _mobs[id] = new MobEntry(ctrl, sprite);
        }
        return sprite;
    }

    /** @private */
    protected function mobRemoved_v1 (targetId :int, id :String) :void
    {
        // TODO: targetId
        Log.getLog(this).debug("Nuking control [id=" + id + "]");
        delete _mobs[id];
    }

    /** @private */
    protected function mobAppearanceChanged_v1 (
        targetId :int, id :String, locArray :Array, orient :Number,
        moving :Boolean, idle :Boolean) :void
    {
        // TODO: targetId
        var entry :MobEntry = _mobs[id];
        if (entry) {
            entry.control.appearanceChanged(locArray, orient, moving, idle);
        }
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

    /** @private */
    protected var _mobs :Dictionary = new Dictionary();
}
}

import flash.display.DisplayObject;

import com.whirled.avrg.MobControl;

class MobEntry
{
    public var control :MobControl;
    public var sprite :DisplayObject;

    public function MobEntry (control :MobControl, sprite :DisplayObject)
    {
        this.control = control;
        this.sprite = sprite;
    }
}
