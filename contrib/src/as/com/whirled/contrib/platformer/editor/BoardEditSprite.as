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

import flash.display.Shape;
import flash.display.Sprite;

import flash.events.MouseEvent;

import com.whirled.contrib.platformer.display.Layer;
import com.whirled.contrib.platformer.util.Metrics;
import com.whirled.contrib.platformer.display.PieceSprite;
import com.whirled.contrib.platformer.display.PieceSpriteFactory;

import com.whirled.contrib.platformer.board.Board;

import com.whirled.contrib.platformer.piece.Piece;
import com.whirled.contrib.platformer.piece.Dynamic;

public class BoardEditSprite extends EditSprite
{
    public function BoardEditSprite (ev :EditView)
    {
        super();
        _ev = ev;
    }

    public function setBoard (board :Board) :void
    {
        if (_board != null) {
            _board.removeEventListener(Board.PIECE_ADDED, pieceAdded);
            clearDisplay();
        }
        _board = board;
        initDisplay();
        _board.addEventListener(Board.PIECE_ADDED, pieceAdded);
        _board.addEventListener(Board.ITEM_UPDATED, itemUpdated);
        _board.addEventListener(Board.GROUP_ADDED, addContainer);
        _board.addEventListener(Board.DYNAMIC_ADDED, dynamicAdded);
        _board.addEventListener(Board.ITEM_REMOVED, removeSprite);
        _board.addEventListener(Board.ITEM_FORWARD, moveSpriteForward);
        _board.addEventListener(Board.ITEM_BACK, moveSpriteBack);
        _board.addEventListener(Board.ITEM_UP, moveSpriteUp);
        _board.addEventListener(Board.ITEM_DOWN, moveSpriteDown);
    }

    public function setSelected (sprite :EditorSprite, updateView :Boolean = true) :void
    {
        for (var ii :int = 0; ii < GRID_LAYER; ii++) {
            _layers[ii].forEach(function (es :*, index :int, array :Array) :void {
                es.setSelected(es == sprite);
            });
        }
        if (sprite != null) {
            if (updateView) {
                var layer :int = -1;
                for (ii = 0; ii < GRID_LAYER; ii++) {
                    if (_layers[ii].contains(sprite)) {
                        layer = ii;
                        break;
                    }
                }
                if (layer > -1) {
                    _ev.selectItem(_layers[layer].getTree(sprite), sprite.name);
                }
            } else {
                ensureOnScreen(sprite);
            }
        }
    }

    public function selectSprite (tree :String, name :String) :void
    {
        var sprite :EditorSprite = _layers[getLayer(tree)].getSprite(tree, name);
        if (sprite != null) {
            setSelected(sprite, false);
        }
    }

    public function resetPieceLayer () :void
    {
        _layers[LEVEL_LAYER].clear();
        _layers[FRONT_LEVEL_LAYER].clear();
        var pieceTree :Array = _board.getPieces();
        addPieces(pieceTree, pieceTree[0]);
    }

    public function resetActorLayer () :void
    {
        _layers[ACTOR_LAYER].clear();
        _layers[DYNAMIC_LAYER].clear();
        for each (var group :String in _board.getGroupNames()) {
            addDynamics(_board.getDynamicIns(group),
                (group == Board.ACTORS ? ACTOR_LAYER : DYNAMIC_LAYER), group);
        }
    }

    public function isOnScreen (sprite :EditorSprite) :Boolean
    {
        return !(sprite.getTileX() + sprite.getTileWidth() <= getX() ||
            sprite.getTileX() >= getX() + Metrics.WINDOW_WIDTH * _scale ||
            sprite.getTileY() + sprite.getTileHeight() <= getY() ||
            sprite.getTileY() >= getY() + Metrics.WINDOW_HEIGHT * _scale);
    }

    override protected function initDisplay () :void
    {
        addChild(_layers[LEVEL_LAYER] = new EditorSpriteLayer());
        addChild(_layers[DYNAMIC_LAYER] = new EditorSpriteLayer());
        addChild(_layers[ACTOR_LAYER] = new EditorSpriteLayer());
        addChild(_layers[FRONT_LEVEL_LAYER] = new EditorSpriteLayer());
        resetPieceLayer();
        resetActorLayer();

        super.initDisplay();
    }

    protected function getLayer (tree :String) :int
    {
        tree = tree.replace(/root(\.)*/, "");
        if (tree.indexOf("front") == 0) {
            return FRONT_LEVEL_LAYER;
        } else if (tree.indexOf(Board.ACTORS) == 0) {
            return ACTOR_LAYER;
        } else if (_board.getGroupNames().indexOf(tree) != -1) {
            return DYNAMIC_LAYER;
        } else {
            return LEVEL_LAYER;
        }
    }

    protected function pieceAdded (p :Piece, tree :String) :void
    {
        _layers[getLayer(tree)].addEditorSprite(new EditorPieceSprite(
                PieceSpriteFactory.getPieceSprite(p), this), tree);
    }

    protected function dynamicAdded (d :Dynamic, tree :String) :void
    {
        _layers[getLayer(tree)].addEditorSprite(new EditorDynamicSprite(
                PieceSpriteFactory.getDynamicSprite(d), this), tree);
    }

    protected function itemUpdated (item :Object, tree :String) :void
    {
        _layers[getLayer(tree)].objectUpdated(item, tree);
    }

    protected function addContainer (name :String, tree :String) :void
    {
        _layers[getLayer(tree)].addContainer(name, tree);
    }

    protected function removeSprite (name :String, tree :String) :void
    {
        _layers[getLayer(tree)].removeSprite(name, tree);
    }

    protected function moveSpriteForward (name :String, tree :String) :void
    {
        _layers[getLayer(tree)].moveSpriteForward(name, tree);
    }

    protected function moveSpriteBack (name :String, tree :String) :void
    {
        _layers[getLayer(tree)].moveSpriteBack(name, tree);
    }

    protected function moveSpriteUp (name :String, tree :String) :void
    {
        _layers[getLayer(tree)].moveSpriteUp(name, tree);
    }

    protected function moveSpriteDown (name :String, tree :String) :void
    {
        _layers[getLayer(tree)].moveSpriteDown(name, tree);
    }

    protected function addPieces (pieces :Array, tree :String) :void
    {
        for each (var node :Object in pieces) {
            if (node is Array) {
                addPieces(node as Array, tree + "." + node[0]);
            } else if (node is Piece) {
                _layers[getLayer(tree)].addEditorSprite(new EditorPieceSprite(
                    PieceSpriteFactory.getPieceSprite(node as Piece), this), tree);
            }
        }
    }

    protected function addDynamics (dynamics :Object, layer :int, group :String) :void
    {
        for each (var d :Dynamic in dynamics) {
            _layers[layer].addEditorSprite(new EditorDynamicSprite(
                PieceSpriteFactory.getDynamicSprite(d), this), "root." + group);
        }
    }

    protected function ensureOnScreen (sprite :EditorSprite) :void
    {
        if (!isOnScreen(sprite)) {
            positionViewTile(
                sprite.getTileX() - (Metrics.WINDOW_WIDTH * _scale - sprite.getTileWidth()) / 2,
                -sprite.getTileY() + (Metrics.WINDOW_HEIGHT * _scale - sprite.getTileHeight()) / 2);
        }
    }

    override protected function updateDisplay () :void
    {
        for each (var layer :Layer in _layers) {
            if (layer != null) {
                layer.update(_bX / _scale, _bY / _scale, _scale);
                if (layer is EditorSpriteLayer) {
                    (layer as EditorSpriteLayer).forEach(
                            function (eps :*, index :int, array :Array) :void {
                        eps.setOnScreen(isOnScreen(eps));
                    });
                }
            }
        }
    }

    override protected function tileChanged (newX :int, newY :int) :void
    {
        for (var ii :int = 0; ii < GRID_LAYER; ii++) {
            _layers[ii].forEach(function (eps :*, index :int, array :Array) :void {
                eps.mouseMove(newX, newY);
            });
        }
    }

    override protected function clearDrag () :void
    {
        for (var ii :int = 0; ii < GRID_LAYER; ii++) {
            _layers[ii].forEach(function (eps :*, index :int, array :Array) :void {
                eps.clearDrag();
            });
        }
    }

    override protected function get GRID_LAYER () :int
    {
        return BOARD_GRID_LAYER;
    }

    protected var _board :Board;

    protected var _ev :EditView;

    protected static const LEVEL_LAYER :int = 0;
    protected static const DYNAMIC_LAYER :int = 1;
    protected static const ACTOR_LAYER :int = 2;
    protected static const FRONT_LEVEL_LAYER :int = 3;
    protected static const BOARD_GRID_LAYER :int = 4;
}
}
