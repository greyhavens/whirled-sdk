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
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;

import flash.text.TextField;

import flash.geom.Point;
import flash.geom.Rectangle;

import com.threerings.util.ArrayIterator;
import com.threerings.util.ClassUtil;

import com.whirled.contrib.platformer.board.Board;
import com.whirled.contrib.platformer.piece.Actor;
import com.whirled.contrib.platformer.piece.BoundedPiece;
import com.whirled.contrib.platformer.piece.Dynamic;
import com.whirled.contrib.platformer.piece.Piece;
import com.whirled.contrib.platformer.piece.Shot;

/**
 * Displays a board.
 */
public class BoardSprite extends Sprite
{
    public static const SHOW_DETAILS :Boolean = false;

    public function BoardSprite (board :Board)
    {
        _board = board;
        _board.addEventListener(Board.ACTOR_ADDED, handleDynamicAdded);
        _board.addEventListener(Board.SHOT_ADDED, handleDynamicAdded);
        _board.addEventListener(Board.DYNAMIC_ADDED, handleDynamicAdded);
        _board.addEventListener(Board.DYNAMIC_REMOVED, handleDynamicRemoved);
        //scaleX = 0.5;
        //scaleY = 0.5;
    }

    public function initDisplay () :void
    {
        var masker :Shape = new Shape();
        masker.graphics.beginFill(0x000000);
        masker.graphics.drawRect(0, 0, Metrics.DISPLAY_WIDTH, Metrics.DISPLAY_HEIGHT);
        masker.graphics.endFill();
        //mask = masker;
        //addChild(masker);

        _layers = new Array(NUM_LAYERS);
        var bxml :XML = _board.getBackgroundXML();
        if (bxml != null) {
            _layers[BG_LAYER] = new BitmapParallaxBackground();
            for each (var l:XML in bxml.layer) {
                _layers[BG_LAYER].addNewLayer(PieceSpriteFactory.instantiateClip(
                        l.resource[0].@name), l.@scrollX, l.@scrollY, l.@x, l.@y);
            }
            addChild(_layers[BG_LAYER]);
        }

        _layers[LEVEL_LAYER] =
            new BitmapSectionalLayer(Metrics.WINDOW_WIDTH, Metrics.WINDOW_HEIGHT);
        //_layers[LEVEL_LAYER] = new PieceSpriteLayer();
        addChild(_layers[LEVEL_LAYER]);
        addChild(_layers[BACK_DYNAMIC_LAYER] = new DynamicSpriteLayer());
        addChild(_layers[BACK_PARTICLE_LAYER] = new ParticleLayer());
        _layers[ACTOR_LAYER] = new ActorSpriteLayer();
        addChild(_layers[ACTOR_LAYER]);
        addChild(_layers[SHOT_LAYER] = new DynamicSpriteLayer());
        addChild(_layers[FRONT_PARTICLE_LAYER] = new ParticleLayer());
        _layers[FRONT_LEVEL_LAYER] =
            new BitmapSectionalLayer(Metrics.WINDOW_WIDTH, Metrics.WINDOW_HEIGHT);
        addChild(_layers[FRONT_LEVEL_LAYER]);
        addPieces(_board.getPieces());
        initBounds();
        centerOn(0, 0);
    }

    public function moveDelta (dX :Number, dY :Number) :void
    {
        _centerX += dX;
        _centerY += dY;
        updateDisplay();
    }

    public function centerOn (nX :Number, nY :Number) :void
    {
        _centerX = nX * Metrics.TILE_SIZE;
        _centerY = nY * Metrics.TILE_SIZE;
        updateDisplay();
    }

    public function ensureVisible (actor :Actor, yshift :Number = 0) :void
    {
        var xbuffer :int = BUFFER * (1 + Math.abs(actor.dx) / 5);
        if (actor.x * Metrics.TILE_SIZE < _centerX + xbuffer) {
            _centerX = actor.x * Metrics.TILE_SIZE - xbuffer;
        } else if ((actor.x + actor.width) * Metrics.TILE_SIZE >
                    _centerX + Metrics.DISPLAY_WIDTH - xbuffer) {
            _centerX = (actor.x + actor.width) * Metrics.TILE_SIZE +
                    xbuffer - Metrics.DISPLAY_WIDTH;
        }
        var x :int = Math.floor(_centerX / Metrics.TILE_SIZE);
        if (x < _minX) {
            _centerX = _minX * Metrics.TILE_SIZE;
            x = _minX;
        } else if (x + 1 + Metrics.WINDOW_WIDTH > _maxX) {
            _centerX = _maxX * Metrics.TILE_SIZE - Metrics.DISPLAY_WIDTH;
            x = _maxX - Metrics.WINDOW_WIDTH;
        }
        var offX :Number = (Math.floor(_centerX) % Metrics.TILE_SIZE) / Metrics.TILE_SIZE;

        if (yshift != 0) {
            _centerY += Metrics.TILE_SIZE * _lastDelta * yshift * 3;
            _lastY = 0;
        } else if (_lastY > Y_ADJUST && actor.y * Metrics.TILE_SIZE > _centerY + LBUFFER) {
            _centerY += Metrics.TILE_SIZE * _lastDelta;

        }

        if (actor.y * Metrics.TILE_SIZE < _centerY + LBUFFER) {
            _centerY = actor.y * Metrics.TILE_SIZE - LBUFFER;
            _lastY = 0;
        } else if ((actor.y + actor.height) * Metrics.TILE_SIZE >
                    _centerY + Metrics.DISPLAY_HEIGHT - BUFFER) {
            _centerY = (actor.y + actor.height) * Metrics.TILE_SIZE +
                        BUFFER - Metrics.DISPLAY_HEIGHT;
            _lastY = 0;
        }

        var offY :Number = Math.floor(_centerY / Metrics.TILE_SIZE);

        if (offY < _lowBounds[x] || offY < _lowBounds[x+1]) {
            _centerY = (_lowBounds[x] + (_lowBounds[x+1] - _lowBounds[x]) * offX) *
                            Metrics.TILE_SIZE;
            _lastY = 0;
        } else if (_highBound > 0 && offY + Metrics.WINDOW_HEIGHT >= _highBound) {
            _centerY = (_highBound - Metrics.WINDOW_HEIGHT) * Metrics.TILE_SIZE;
            _lastY = 0;
        }

        updateDisplay();
    }

    public function tick (delta :Number) :void
    {
        updateActors(delta);
        _lastDelta = delta;
        _lastY += delta;
    }

    public function updateActors (delta :Number) :void
    {
        _layers[BACK_DYNAMIC_LAYER].updateSprites(delta);
        _layers[ACTOR_LAYER].updateSprites(delta);
        _layers[SHOT_LAYER].updateSprites(delta);
    }

    public function setHighBound (bound :int) :void
    {
        _highBound = bound;
    }

    protected function addPieces (pieces :Array, layer :int = -1) :void
    {
        for each (var node :Object in pieces) {
            if (node is Piece && layer != -1) {
                var p :Piece = node as Piece;
                var sprite :PieceSprite = PieceSpriteFactory.getPieceSprite(p);
                if (p is BoundedPiece) {
                    sprite.showDetails(SHOW_DETAILS);
                }
                _layers[layer].addPieceSprite(sprite);
                for (var xx :int = p.x; xx < p.x + p.width; xx++) {
                    if (_lowBounds[xx] == null || _lowBounds[xx] > p.y) {
                        _lowBounds[xx] = p.y;
                    }
                }
                if (p.x < _minX) {
                    _minX = p.x;
                }
                if (p.x + p.width > _maxX) {
                    _maxX = p.x + p.width;
                }
            } else if (node is Array) {
                addPieces(node as Array, layer);
            } else if (layer == -1 && node is String) {
                if ((node as String) == "front") {
                    layer = FRONT_LEVEL_LAYER;
                } else if ((node as String) == "back") {
                    layer = LEVEL_LAYER;
                }
            }
        }
    }

    protected function initBounds () :void
    {
        for (var xx :int = _minX; xx <= _maxX; xx++) {
            var yy :int = 0;
            for (var ii :int = xx, ll :int = Math.min(_maxX, xx + Metrics.WINDOW_WIDTH + 1);
                    ii <= ll; ii++) {
                if (_lowBounds[ii] != null && _lowBounds[ii] > yy) {
                    yy = _lowBounds[ii];
                }
            }
            _lowBounds[xx] = yy;
            if (xx > _minX && _lowBounds[xx-1] - 1 > _lowBounds[xx]) {
                _lowBounds[xx] = _lowBounds[xx - 1] - 1;
            }
        }
        for (xx = _maxX - 1; xx >= _minX; xx--) {
            if (_lowBounds[xx + 1] - 1 > _lowBounds[xx]) {
                _lowBounds[xx] = _lowBounds[xx + 1] - 1;
            }
        }
        _maxX = Math.max(_maxX, _minX + Metrics.WINDOW_WIDTH);
    }

    protected function handleDynamicAdded (d :Dynamic, group :String) :void
    {
        var ds :DynamicSprite = PieceSpriteFactory.getDynamicSprite(d);
        if (d is Actor) {
            _layers[ACTOR_LAYER].addDynamicSprite(ds);
        } else if (d is Shot) {
            _layers[SHOT_LAYER].addDynamicSprite(ds);
        } else {
            _layers[BACK_DYNAMIC_LAYER].addDynamicSprite(ds);
        }
        ds.setParticleCallback(addParticleEffect);
    }

    protected function handleDynamicRemoved (d :Dynamic, group :String) :void
    {
        if (d is Actor) {
            _layers[ACTOR_LAYER].removeDynamicSprite(d);
        } else if (d is Shot) {
            _layers[SHOT_LAYER].removeDynamicSprite(d);
        } else {
            _layers[BACK_DYNAMIC_LAYER].removeDynamicSprite(d);
        }
    }

    protected function addParticleEffect (disp :DisplayObject, pt :Point, back :Boolean) :void
    {
        var layer :int = back ? BACK_PARTICLE_LAYER : FRONT_PARTICLE_LAYER;
        _layers[layer].addParticleEffect(disp, pt);
    }

    protected function updateDisplay () :void
    {
        for each (var layer :Layer in _layers) {
            layer.update(_centerX, _centerY);
        }
    }

    /** The board we're visualizing. */
    protected var _board :Board;

    /** The board layer. */
    protected var _layers :Array;

    protected var _centerX :Number = 0;
    protected var _centerY :Number = 0;

    protected var _showBG :Boolean = true;

    protected var _lowBounds :Array = new Array();
    protected var _highBound :int;
    protected var _minX :int = int.MAX_VALUE;
    protected var _maxX :int = 0;
    protected var _lastY :Number = 0;
    protected var _lastDelta :Number = 0;

    protected static const PARALLAX :int = 5;

    protected static const BG_LAYER :int = 0;
    protected static const LEVEL_LAYER :int = 1;
    protected static const BACK_DYNAMIC_LAYER :int = 2;
    protected static const BACK_PARTICLE_LAYER :int = 3;
    protected static const ACTOR_LAYER :int = 4;
    protected static const SHOT_LAYER :int = 5;
    protected static const FRONT_PARTICLE_LAYER :int = 6;
    protected static const FRONT_LEVEL_LAYER :int = 7;
    protected static const NUM_LAYERS :int = 8;

    protected static const BUFFER :int = Metrics.TILE_SIZE*3;
    protected static const LBUFFER :int = Metrics.TILE_SIZE;
    protected static const Y_ADJUST :Number = 2;
}
}
