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

package com.whirled.contrib.platformer.editor {

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;

import com.whirled.contrib.platformer.display.Metrics;
import com.whirled.contrib.platformer.display.Layer;

public class EditorSpriteLayer extends Layer
{
    public function addEditorSprite (es :EditorSprite, tree :String) :void
    {
        var container :DisplayObjectContainer = getContainer(tree);
        container.addChild(es);
        _esprites.push(es);
    }

    public function objectUpdated (o :Object, tree :String) :void
    {
        var container :DisplayObjectContainer = getContainer(tree);
        var sprite :DisplayObject = container.getChildByName(o.id.toString());
        if (sprite != null) {
            (sprite as Object).update();
        }
    }

    public function addContainer (name :String, tree :String) :void
    {
        var container :DisplayObjectContainer = getContainer(tree);
        var next :Sprite = new Sprite();
        next.name = name;
        container.addChild(next);
    }

    public function removeSprite (name :String, tree :String) :void
    {
        var container :DisplayObjectContainer = getContainer(tree);
        var sprite :DisplayObject = container.getChildByName(name);
        if (sprite != null) {
            container.removeChild(sprite);
        }
    }

    public function moveSpriteForward (name :String, tree :String) :void
    {
        var container :DisplayObjectContainer = getContainer(tree);
        var sprite :DisplayObject = container.getChildByName(name);
        if (sprite == null) {
            return;
        }
        var index :int = container.getChildIndex(sprite);
        if (index < container.numChildren - 1) {
            container.removeChildAt(index);
            container.addChildAt(sprite, index + 1);
        }
    }

    public function moveSpriteBack (name :String, tree :String) :void
    {
        var container :DisplayObjectContainer = getContainer(tree);
        var sprite :DisplayObject = container.getChildByName(name);
        if (sprite == null) {
            return;
        }
        var index :int = container.getChildIndex(sprite);
        if (index > 0) {
            container.removeChildAt(index);
            container.addChildAt(sprite, index - 1);
        }
    }

    public function moveSpriteUp (name :String, tree :String) :void
    {
        var container :DisplayObjectContainer = getContainer(tree);
        var upc :DisplayObjectContainer =
            getContainer(tree.substring(0, tree.lastIndexOf(".")));
        var sprite :DisplayObject = container.getChildByName(name);
        if (sprite == null) {
            return;
        }
        container.removeChild(sprite);
        upc.addChildAt(sprite, upc.getChildIndex(container));
    }

    public function moveSpriteDown (name :String, tree :String) :void
    {
        var container :DisplayObjectContainer = getContainer(tree);
        var sprite :DisplayObject = container.getChildByName(name);
        if (sprite == null) {
            return;
        }
        var newc :DisplayObjectContainer;
        for (var ii :int = container.getChildIndex(sprite) + 1; ii < container.numChildren; ii++) {
            if (!(container.getChildAt(ii) is EditorPieceSprite)) {
                    newc = container.getChildAt(ii) as DisplayObjectContainer;
                break;
            }
        }
        if (newc != null) {
            container.removeChild(sprite);
            newc.addChildAt(sprite, 0);
        }
    }

    public function forEach (func :Function) :void
    {
        _esprites.forEach(func);
    }

    public function clear () :void
    {
        _esprites = new Array();
        for (var ii :int = numChildren - 1; ii >= 0; ii--) {
            removeChildAt(ii);
        }
    }

    public function getSprite (tree :String, name :String) :EditorSprite
    {
        var container :DisplayObjectContainer = getContainer(tree);
        var sprite :DisplayObject = container.getChildByName(name);
        if (sprite is EditorSprite) {
            return sprite as EditorSprite;
        }
        return null;
    }

    public function getTree (sprite :DisplayObject) :String
    {
        sprite = sprite.parent;
        var tree :String = sprite.name;
        while (sprite.parent != this) {
            sprite = sprite.parent;
            tree = sprite.name + "." + tree;
        }
        return tree;
    }

    override public function update (nX :Number, nY :Number, scale :Number = 1) :void
    {
        scaleX = 1 / scale;
        scaleY = 1 / scale;
        x = Math.floor(-nX);
        y = Math.floor(Metrics.DISPLAY_HEIGHT - nY);
    }

    protected function getContainer (tree :String) :DisplayObjectContainer
    {
        var container :DisplayObjectContainer = this;
        if (tree == null) {
            return container;
        }
        for each (var name :String in tree.split(".")) {
            var next :DisplayObject = container.getChildByName(name);
            if (next == null) {
                next = new Sprite();
                next.name = name;
                container.addChild(next);
                container = next as DisplayObjectContainer;
            } else {
                container = next as DisplayObjectContainer;
            }
        }
        return container;
    }

    protected var _esprites :Array = new Array();
}
}
