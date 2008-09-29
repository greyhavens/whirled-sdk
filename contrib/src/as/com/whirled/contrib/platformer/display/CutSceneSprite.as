// Whirled contrib library - tools for developing whirled games
// http://www.whirled.com/code/contrib/asdocs
//
// This library is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library.  If not, see <http://www.gnu.org/licenses/>.
//
// Copyright 2008 Three Rings Design
//
// $Id$

package com.whirled.contrib.platformer.display {

import flash.display.DisplayObject;

import com.whirled.contrib.platformer.piece.CutScene;

public class CutSceneSprite extends DynamicSprite
{
    public static const IDLE :String = "idle";
    public static const INTRO :String = "_in";
    public static const BODY :String = "_stop";
    public static const OUTRO :String = "_out";
    public static const HOVER :String = "loop_repeat";
    public static const END :String = "idle_end";
    public static const REPEAT :String = "idle_repeat";

    public function CutSceneSprite (cs :CutScene, disp :DisplayObject = null)
    {
        _cs = cs;
        super(cs, disp);
        if (_disp != null) {
            _disp.x = cs.width/2 * Metrics.TILE_SIZE;
            addChild(_disp);
        }
        update(0);
    }

    override public function update (delta :Number) :void
    {
        super.update(delta);
        if (_cs.stage == 0) {
            changeState(IDLE);
        } else if (_cs.stage == _cs.stageChanges.length + 1) {
            if (_cs.hovered) {
                if (_state != END && _state != HOVER) {
                    changeState(REPEAT);
                } else {
                    changeState(HOVER);
                }
            } else {
                changeState(END);
            }
        } else {
            var mode :int = (_cs.stage - 1) % 3;
            var stage :String = Math.floor((_cs.stage + 2) / 3).toString();
            switch (mode) {
            case 0:
                stage += INTRO;
                break;
            case 2:
                stage += OUTRO;
                break;
            default:
                stage += BODY;
            }
            changeState(stage);
        }
    }

    override protected function changeState (state :String) :void
    {
        if (state != _state) {
            trace("CutScene: " + state);
        }
        super.changeState(state);
    }

    protected var _cs :CutScene;
}
}
