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
import flash.display.GradientType;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.geom.Matrix;
import flash.system.ApplicationDomain;
import flash.utils.ByteArray;

import com.threerings.util.ClassUtil;
import com.threerings.util.HashMap;
import com.threerings.util.Log;
import com.threerings.util.MultiLoader;

import com.whirled.contrib.platformer.piece.Actor;
import com.whirled.contrib.platformer.piece.BoundedPiece;
import com.whirled.contrib.platformer.piece.CutScene;
import com.whirled.contrib.platformer.piece.Dynamic;
import com.whirled.contrib.platformer.piece.Hover;
import com.whirled.contrib.platformer.piece.LaserShot;
import com.whirled.contrib.platformer.piece.Piece;
import com.whirled.contrib.platformer.piece.Shot;
import com.whirled.contrib.platformer.piece.Spawner;

/**
 * Generates a piece sprite from the supplied piece.
 */
public class PieceSpriteFactory
{
    public static function init (
        sources :Array, onReady :Function, duplicate :Boolean = true) :void
    {
        _duplicate = duplicate;
        MultiLoader.getLoaders(sources, function (result :Object) :void {
                onReady();
            }, false, _contentDomain);
        addPieceClass(Piece, PieceSprite, true);
        addPieceClass(BoundedPiece, BoundedPieceSprite);
        addDynamicClass(Actor, ActorSprite, true);
        addDynamicClass(Shot, ShotSprite);
        addDynamicClass(LaserShot, LaserShotSprite);
        addDynamicClass(Hover, HoverSprite);
        addDynamicClass(CutScene, CutSceneSprite);
        addDynamicClass(Spawner, SpawnerSprite);
    }

    public static function addPieceClass (
            source :Class, sprite :Class, isDefault :Boolean = false) :void
    {
        _spriteMap.put(ClassUtil.getClassName(source), sprite);
        if (isDefault) {
            _defaultPieceSprite = sprite;
        }
    }

    public static function addDynamicClass (
            source :Class, sprite :Class, isDefault :Boolean = false) :void
    {
        _spriteMap.put(ClassUtil.getClassName(source), sprite);
        if (isDefault) {
            _defaultDynamicSprite = sprite;
        }
    }

    public static function getPieceSprite (p :Piece) :PieceSprite
    {
        var pclass :Class = _spriteMap.get(ClassUtil.getClassName(p));
        if (pclass == null) {
            pclass = _defaultPieceSprite;
        }

        return new pclass(p, instantiatePClip(p)) as PieceSprite;
    }

    public static function getDynamicSprite (d :Dynamic) :DynamicSprite
    {
        var dclass :Class = _spriteMap.get(ClassUtil.getClassName(d));
        if (dclass == null) {
            dclass = _defaultDynamicSprite;
        }

        return new dclass(d, instantiateDClip(d));
    }

    public static function blockShape (w :int, h :int, offset :Number = 0) :MovieClip
    {
        var block :MovieClip = new MovieClip();
        var bMatrix :Matrix = new Matrix();
        bMatrix.createGradientBox(w*Metrics.TILE_SIZE, h*Metrics.TILE_SIZE, Math.PI / 4);
        block.graphics.beginGradientFill(
                GradientType.LINEAR, [0xCC0000, 0x330000], [1, 1], [0x00, 0xFF], bMatrix);
        block.graphics.lineStyle(0, 0x888888);
        block.graphics.drawRect(
                offset*Metrics.TILE_SIZE, 0, (w+offset)*Metrics.TILE_SIZE, -h*Metrics.TILE_SIZE);
        block.graphics.endFill();
        return block;
    }

    public static function instantiatePClip (p :Piece) :DisplayObject
    {
        if (p.sprite == null || p.sprite == "") {
            return null;
        }
        var ret :DisplayObject;
        if (!_duplicate) {
            ret = _instanceMap.get(p.sprite);
        }
        if (ret == null) {
            ret = instantiateClip(p.sprite);
            if (ret == null) {
                ret = blockShape(p.width, p.height, -p.width/2);
            }
            if (!_duplicate) {
                _instanceMap.put(p.sprite, ret);
            }
        }
        return ret;
    }

    public static function instantiateDClip (d :Dynamic) :DisplayObject
    {
        if (d.sprite == null || d.sprite == "") {
            return null;
        }
        var ret :DisplayObject = instantiateClip(d.sprite);
        if (ret == null) {
            if (d is Actor) {
                var a :Actor = d as Actor;
                ret = blockShape(a.width, a.height, -a.width/2);
            } else if (d.hasOwnProperty("width") && d.hasOwnProperty("height")) {
                var o :Object = d;
                ret = blockShape(o.width, o.height);
            } else {
                ret = blockShape(0.1, 0.1, -0.05);
            }
        }
        ret.cacheAsBitmap = true;
        return ret;
    }

    public static function instantiateClip (name :String) :DisplayObject
    {
        try {
            var symbolClass :Class = _contentDomain.getDefinition(name) as Class;
            return (new symbolClass() as MovieClip);
        } catch (e :Error) {
            log.warning("Failed to load sprite [" + e + "]. Stack trace follows");
            log.logStackTrace(e);
        }
        return null;
    }

    protected static var _duplicate :Boolean;
    protected static var _spriteMap :HashMap = new HashMap();
    protected static var _instanceMap :HashMap = new HashMap();
    protected static var _defaultPieceSprite :Class;
    protected static var _defaultDynamicSprite :Class;

    protected static var _contentDomain :ApplicationDomain = new ApplicationDomain(null);

    private static const log :Log = Log.getLog(PieceSpriteFactory);
}
}
