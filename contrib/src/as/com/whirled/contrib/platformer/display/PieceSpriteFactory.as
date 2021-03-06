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

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.GradientType;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.events.ProgressEvent;
import flash.geom.Matrix;
import flash.system.ApplicationDomain;
import flash.utils.ByteArray;

import com.threerings.util.ClassUtil;
import com.threerings.util.Log;
import com.threerings.util.Map;
import com.threerings.util.Maps;
import com.threerings.util.MultiLoader;

import com.whirled.contrib.ZipMultiLoader;
import com.whirled.contrib.platformer.piece.Actor;
import com.whirled.contrib.platformer.piece.BoundedPiece;
import com.whirled.contrib.platformer.piece.DestructableGate;
import com.whirled.contrib.platformer.piece.Dynamic;
import com.whirled.contrib.platformer.piece.Gate;
import com.whirled.contrib.platformer.piece.Hover;
import com.whirled.contrib.platformer.piece.LaserShot;
import com.whirled.contrib.platformer.piece.Piece;
import com.whirled.contrib.platformer.piece.Shot;
import com.whirled.contrib.platformer.piece.Spawner;
import com.whirled.contrib.platformer.util.Metrics;

/**
 * Generates a piece sprite from the supplied piece.
 */
public class PieceSpriteFactory
{
    public static function init (
        sources :Array, onReady :Function, duplicate :Boolean = true) :void
    {
        MultiLoader.getLoaders(sources, function (result :Object) :void {
                onReady();
            }, false, _contentDomain);
        initClasses(duplicate);
    }

    public static function initZip (source :Object, onReady :Function, duplicate :Boolean = true,
        progressListener :Function = null) :void
    {
        var loader :ZipMultiLoader = new ZipMultiLoader(source, function (result :Object) :void {
                onReady();
            }, _contentDomain);
        if (progressListener != null) {
            loader.addEventListener(ProgressEvent.PROGRESS, progressListener);
        }
        initClasses(duplicate);
    }

    public static function initClasses (duplicate :Boolean) :void
    {
        _duplicate = duplicate;
        addPieceClass(Piece, PieceSprite, true);
        addPieceClass(BoundedPiece, BoundedPieceSprite);
        addDynamicClass(Actor, ActorSprite, true);
        addDynamicClass(Shot, ShotSprite);
        addDynamicClass(LaserShot, LaserShotSprite);
        addDynamicClass(Hover, HoverSprite);
        addDynamicClass(Spawner, SpawnerSprite);
        addDynamicClass(Gate, GateSprite);
        addDynamicClass(DestructableGate, DestructableGateSprite);
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
        if (!_duplicate) {
            var ps :PieceSprite = new pclass(p, null, true);
            ps.setBitmap(instantiatePBitmap(p));
            return ps;
        }
        return new pclass(p, instantiatePClip(p), false) as PieceSprite;
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
        var ret :DisplayObject = instantiateClip(p.sprite);
        if (ret == null) {
            ret = blockShape(p.width, p.height, -p.width/2);
        }
        return ret;
    }

    public static function instantiatePBitmap (p :Piece) :BitmapData
    {
        if (p.sprite == null || p.sprite == "") {
            return null;
        }
        var arr :Array = _instanceMap[p.sprite];
        if (arr == null) {
            arr = new Array(2);
            _instanceMap[p.sprite] = arr;
        }
        var wrapper :BDWrapper = arr[p.orient];
        if (wrapper == null) {
            var disp :DisplayObject = instantiateClip(p.sprite);
            if (disp == null) {
                disp = blockShape(p.width, p.height, -p.width/2);
            }
            //bd = new BitmapData(p.width * Metrics.TILE_SIZE, p.height * Metrics.TILE_SIZE, true, 0x00000000);
            wrapper = new BDWrapper();
            wrapper.bd = new BitmapData((p.sWidth) * Metrics.TILE_SIZE,
                    (p.sHeight) * Metrics.TILE_SIZE, true, 0x00000000);
            var mat :Matrix = new Matrix();
            if (p.orient == 0) {
                mat.scale(Metrics.SCALE, Metrics.SCALE);
                mat.translate(p.nudgeX ? Metrics.TILE_SIZE : 0,
                        (p.sHeight - (p.nudgeY ? 1 : 0)) * Metrics.TILE_SIZE);
            } else {
                mat.scale(-Metrics.SCALE, Metrics.SCALE);
                mat.translate((p.width + (p.nudgeW ? 1 : 0)) * Metrics.TILE_SIZE,
                        (p.sHeight - (p.nudgeY ? 1 : 0)) * Metrics.TILE_SIZE);
            }
            wrapper.bd.draw(disp, mat);
            arr[p.orient] = wrapper;
        }
        wrapper.isOld = false;
        return wrapper.bd;
    }

    public static function markOldBitmaps () :void
    {
        if (_duplicate) {
            return;
        }
        for each (var arr :Array in _instanceMap) {
            for each (var wrapper :BDWrapper in arr) {
                if (wrapper != null) {
                    wrapper.isOld = true;
                }
            }
        }
    }

    public static function clearOldBitmaps () :void
    {
        if (_duplicate) {
            return;
        }
        for each (var arr :Array in _instanceMap) {
            for (var ii :int; ii < arr.length; ii++) {
                if (arr[ii] != null && arr[ii].isOld) {
                    arr[ii].bd.dispose();
                    arr[ii] = null;
                }
            }
        }
    }

    public static function instantiateDClip (d :Dynamic) :DisplayObject
    {
        if (d.sprite == null || d.sprite == "") {
            return null;
        }
        var ret :DisplayObject = d.useCache() ? loadCacheDisp(d.sprite) : instantiateClip(d.sprite);
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
        if (ret is MovieClip) {
            (ret as MovieClip).enabled = false;
        }
        return ret;
    }

    public static function instantiateClip (name :String) :DisplayObject
    {
        try {
            var symbolClass :Class = _contentDomain.getDefinition(name) as Class;
            return (new symbolClass() as DisplayObject);
        } catch (e :Error) {
            log.warning("Failed to load sprite [" + e + "]. Stack trace follows");
            log.logStackTrace(e);
        }
        return null;
    }

    public static function loadCache (name :String) :Object
    {
        /*
        var cache :Array = _clipCache[name];
        if (cache == null || cache.length == 0) {
            return null;
        }
        return cache.pop();
        */
        return null;
    }

    public static function loadCacheDisp (name :String) :DisplayObject
    {
        var disp :DisplayObject = loadCache(name) as DisplayObject;
        if (disp == null) {
            return instantiateClip(name);
        }
        return disp;

    }

    public static function loadCacheWrapper (name :String) :CacheWrapper
    {
        var cw :CacheWrapper = loadCache(name) as CacheWrapper;
        if (cw == null) {
            var disp :DisplayObject = instantiateClip(name);
            if (disp != null) {
                cw = new CacheWrapper(name, disp);
            }
        }
        return cw;
    }

    public static function pushCache (name :String, o :Object) :void
    {
        /*
        var cache :Array = _clipCache[name];
        if (cache == null) {
            cache = new Array();
            _clipCache[name] = cache;
        }
        cache.push(o);
        */
    }

    public static function returnCacheWrapper (cw :CacheWrapper) :void
    {
        pushCache(cw.name, cw);
    }

    protected static var _duplicate :Boolean;
    protected static var _spriteMap :Map = Maps.newMapOf(String);
    protected static var _instanceMap :Object = new Object();
    protected static var _defaultPieceSprite :Class;
    protected static var _defaultDynamicSprite :Class;
    protected static var _mat :Matrix;

    protected static var _contentDomain :ApplicationDomain = new ApplicationDomain(null);

    protected static var _clipCache :Object = new Object();

    private static const log :Log = Log.getLog(PieceSpriteFactory);
}
}

import flash.display.BitmapData;

class BDWrapper
{
    public var bd :BitmapData;
    public var isOld :Boolean;
}
