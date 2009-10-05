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

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

import flash.events.Event;

import flash.filters.ColorMatrixFilter;

import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Transform;

import com.threerings.display.ColorMatrix;
import com.whirled.contrib.sound.SoundEffect;

import com.whirled.contrib.platformer.PlatformerContext;
import com.whirled.contrib.platformer.client.ClientPlatformerContext;
import com.whirled.contrib.platformer.piece.Dynamic;
import com.whirled.contrib.platformer.util.Effect;
import com.whirled.contrib.platformer.util.Metrics;

public class DynamicSprite extends Sprite
{
    public static const NORMAL :int = 0;
    public static const ALWAYS :int = 1;
    public static const NEVER :int = 2;
    public static const UNTIL_REMOVED :int = 3;

    public function DynamicSprite (dy :Dynamic, disp :DisplayObject = null)
    {
        _dynamic = dy;
        _disp = disp;
        addEventListener(Event.ADDED, handleAdded);
        addEventListener(Event.REMOVED, handleRemoved);
        this.x = _dynamic.x * Metrics.SOURCE_TILE_SIZE;
        this.y = -_dynamic.y * Metrics.SOURCE_TILE_SIZE;
        /*
        this.scaleX = Metrics.SCALE;
        this.scaleY = Metrics.SCALE;
        */

        if (dy.soundEvents != null && disp != null) {
            if ((dy.soundEvents.length % 2) != 0) {
                trace("Dynamic.soundEvents must be even in length! [" + dy + "]");
                return;
            }
            for (var ii :int = 0; ii < dy.soundEvents.length; ii += 2) {
                var soundEffect :SoundEffect =
                    PlatformerContext.getSoundEffect(dy.soundEvents[ii+1] as String);
                registerDispEventListener(
                        dy.soundEvents[ii] as String, bindSoundEffectPlayback(soundEffect));
            }
        }
    }

    public function get displayWidth () :Number
    {
        return (_dynamic.getBounds().width + 1) * Metrics.SOURCE_TILE_SIZE;
    }

    public function get displayHeight () :Number
    {
        return (_dynamic.getBounds().height + 1) * Metrics.SOURCE_TILE_SIZE;
    }

    public function shutdown () :void
    {
        removeEventListener(Event.ADDED, handleAdded);
        removeEventListener(Event.REMOVED, handleRemoved);
        clearDisp();
    }

    public function getDynamic () :Dynamic
    {
        return _dynamic;
    }

    public function showState () :int
    {
        return NORMAL;
    }

    public function update (delta :Number) :void
    {
        this.x = _dynamic.x * Metrics.SOURCE_TILE_SIZE;
        this.y = -_dynamic.y * Metrics.SOURCE_TILE_SIZE;
        if (_hitLeft > 0) {
            _hitLeft -= delta;
            if (_hitLeft <= 0) {
                var filters :Array = _disp.filters;
                if (filters != null) {
                    // Adding a filter to a DisplayObject changes the filter, so you can't compare
                    // the filter to figure out which one it is in the array.  So we're left with
                    // maintaining an index, and hoping that the filters haven't changed so that
                    // we remove the correct one.  Thank you ActionScript.
                    filters.splice(_hitFilterIndex, 1);
                    _disp.filters = filters;
                }
            }
        }
    }

    public function setParticleCallback (callback :Function) :void
    {
        _particleCallback = callback;
    }

    public function setStatic (s :Boolean) :void
    {
        _static = s;
    }

    public function forceBack () :Boolean
    {
        return false;
    }

    protected function handleAdded (event :Event) :void
    {
        if (event.target != this) {
            return;
        }
        onAdded();
    }

    protected function onAdded () :void
    {
        playState();
    }

    protected function handleRemoved (event :Event) :void
    {
        if (event.target != this) {
            return;
        }
        onRemoved();
    }

    protected function onRemoved () :void
    {
        if (_disp is MovieClip) {
            (_disp as MovieClip).stop();
        }
    }

    protected function changeState (newState :int) :void
    {
        if (_state != newState) {
            _state = newState;
            if (stage != null) {
                playState();
            }
        }
    }

    protected function playState () :void
    {
        if (_disp is MovieClip) {
            if (_static) {
                (_disp as MovieClip).gotoAndStop(getStateFrame(_state));
            } else {
                //trace("goto and play: " + _state);
                (_disp as MovieClip).gotoAndPlay(getStateFrame(_state));
            }
        }
    }

    protected function generateEffect (
            effect :Effect, node :DisplayObject, filter :ColorMatrixFilter = null,
            scaleY :Number = 1) :void
    {
        if (_particleCallback != null && stage != null && node != null && effect != null) {
            if (!effect.shouldShow(ClientPlatformerContext.prefs.effectLevel)) {
                return;
            }
            var cw :CacheWrapper = PieceSpriteFactory.loadCacheWrapper(effect.effect);
            //var disp :DisplayObject = PieceSpriteFactory.instantiateClip(name);
            if (cw == null) {
                return;
            }
            cw.disp.scaleY = scaleY;
            cw.disp.scaleX = effect.flip ? -1 : 1;
            var pt :Point = node.localToGlobal(new Point());
            var opt :Point = node.localToGlobal(new Point(0, 0));
            var apt :Point = node.localToGlobal(new Point(0, -1));
            apt = apt.subtract(opt);
            apt.normalize(1);
            cw.disp.rotation = -90 + (Math.atan2(apt.y, apt.x) - Math.atan2(0, -1)) * 180 / Math.PI;
            cw.recolor(effect.recolor, filter);
            if (effect.soundEvents != null && effect.soundEvents.length > 0) {
                if ((effect.soundEvents.length % 2) != 0) {
                    trace("Effect.soundEvents is required to be even in length! [" + effect + "]");
                } else {
                    for (var ii :int = 0; ii < effect.soundEvents.length; ii += 2) {
                        cw.addDispListener(effect.soundEvents[ii] as String,
                            bindSoundEffectPlayback(effect.soundEvents[ii+1] as SoundEffect));
                    }
                }
            }
            _particleCallback(cw, pt, effect.back);
        }
    }

    protected function registerDispEventListener (event :String, func :Function) :void
    {
        if (_disp != null) {
            _disp.addEventListener(event, func);
            if (_listeners == null) {
                _listeners = new Object();
            }
            _listeners[event] = func;
        }
    }

    protected function bindSoundEffectPlayback (soundEffect :SoundEffect) :Function
    {
        return function (...ignored) :void {
            playSoundEffect(soundEffect);
        };
    }

    protected function generateAttachedEffect (name :String, node :DisplayObjectContainer) :void
    {
        if (stage == null || name == null || node == null) {
            return;
        }
        var disp :DisplayObject = PieceSpriteFactory.instantiateClip(name);
        if (disp == null) {
            return;
        }
        disp.addEventListener(Event.COMPLETE, function (event :Event) :void {
            if (event.target == disp) {
                event.stopPropagation();
                disp.parent.removeChild(disp);
                disp.removeEventListener(Event.COMPLETE, arguments.callee);
            }
        });
        node.addChild(disp);
    }

    protected function recolorNodesToColor (
        node :String, disp :DisplayObject, color :int) :ColorMatrixFilter
    {
        return DisplayUtils.recolorNodesToColor(node, disp, color);
    }

    protected function recolorNodes (
        node :String, disp :DisplayObject, filter :ColorMatrixFilter) :void
    {
        DisplayUtils.recolorNodes(node, disp, filter);
    }

    protected function showHit (filter :ColorMatrixFilter = null,
        length :Number = HIT_LENGTH) :Boolean
    {
        if (_hitLeft <= 0 && stage != null) {
            _hitLeft = length;
            if (filter == null) {
                if (_hitFilter == null) {
                    var matrix :ColorMatrix = new ColorMatrix();
                    matrix.tint(0xFFE377, 0.5);
                    _hitFilter = matrix.createFilter();
                }
                filter = _hitFilter;
            }
            var filters :Array = _disp.filters;
            if (filters == null) {
                _disp.filters = [filter];
                _hitFilterIndex = 0;
            } else {
                _hitFilterIndex = filters.length;
                filters.push(filter);
                _disp.filters = filters;
            }
            return true;
        }
        return false;
    }

    protected function clearDisp () :void
    {
        if (_disp != null) {
            if (_disp.parent == this) {
                removeChild(_disp);
            }
            for (var event :String in _listeners) {
                _disp.removeEventListener(event, _listeners[event]);
            }
            if (_dynamic.useCache()) {
                //PieceSpriteFactory.pushCache(_dynamic.sprite, _disp);
            }
            _disp = null;
        }
    }

    protected function getStateFrame (state :int) :Object
    {
        return 1;
    }

    protected function playSoundEffect (effect :SoundEffect) :void
    {
        if (effect != null && ClientPlatformerContext.sound != null) {
            var screenCenterX :Number = ClientPlatformerContext.boardSprite.centerX +
                Metrics.DISPLAY_WIDTH / 2;
            var screenCenterY :Number = ClientPlatformerContext.boardSprite.centerY +
                Metrics.DISPLAY_HEIGHT / 2;
            var xNormal :Number = (x - (screenCenterX / Metrics.SCALE)) / SOUND_NORMAL_DISTANCE;
            var yNormal :Number = (-y - (screenCenterY / Metrics.SCALE)) / SOUND_NORMAL_DISTANCE;
            if (Math.abs(xNormal) > 1 || Math.abs(yNormal) > 1) {
                // not playing this effect
                return;
            }

            ClientPlatformerContext.sound.playEffect(
                effect, _dynamic.id, new Point(xNormal, yNormal));
        }
    }

    protected function stopSoundEffect (effect :SoundEffect) :void
    {
        if (effect != null && ClientPlatformerContext.sound != null) {
            ClientPlatformerContext.sound.stopEffect(effect, _dynamic.id);
        }
    }

    protected function setSoundEffectPlaying (effect :SoundEffect, playing :Boolean) :void
    {
        if (effect == null) {
            return;
        }

        if (playing) {
            playSoundEffect(effect);
        } else {
            stopSoundEffect(effect);
        }
    }

    protected function findNode (node :String, disp :DisplayObject) :DisplayObject
    {
        return DisplayUtils.findNode(node, disp);
    }

    //protected var _state :String = "";
    //protected var _stateArray :Array;
    protected var _state :int = -1;
    protected var _dynamic :Dynamic;
    protected var _disp :DisplayObject;
    protected var _particleCallback :Function;
    protected var _static :Boolean;
    protected var _listeners :Object;

    protected var _hitLeft :Number = 0;
    protected var _hitFilter :ColorMatrixFilter;
    protected var _hitFilterIndex :int;

    protected static const HIT_LENGTH :Number = 0.1;

    protected static const SOUND_NORMAL_DISTANCE :Number = Metrics.DISPLAY_HEIGHT * 2;
}
}
