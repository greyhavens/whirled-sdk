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

package com.whirled.contrib.platformer.board {

import com.threerings.util.ArrayIterator;
import com.threerings.util.ClassUtil;
import com.threerings.util.HashMap;

import com.whirled.contrib.platformer.piece.Actor;
import com.whirled.contrib.platformer.piece.BoundedPiece;
import com.whirled.contrib.platformer.piece.Dynamic;
import com.whirled.contrib.platformer.piece.Piece;
import com.whirled.contrib.platformer.piece.PieceFactory;
import com.whirled.contrib.platformer.piece.Shot;

/**
 * The base class for a board which contains pieces.
 */
public class Board
{
    public static const PIECE_ADDED :String = "added";
    public static const PIECE_LOADED :String = "loaded";
    public static const PIECE_REMOVED :String = "removed";
    public static const ITEM_UPDATED :String = "updated";
    public static const ITEM_FORWARD :String = "forward";
    public static const ITEM_BACK :String = "back";
    public static const ITEM_UP :String = "up";
    public static const ITEM_DOWN :String = "down";
    public static const GROUP_ADDED :String = "group_added";
    public static const ITEM_REMOVED :String = "item_removed";
    public static const ACTOR_ADDED :String = "actor_added";
    public static const SHOT_ADDED :String = "shot_added";
    public static const DYNAMIC_ADDED :String = "dynamic_added";
    public static const DYNAMIC_REMOVED :String = "dynamic_removed";

    public function loadFromXML (level :XML, pfac :PieceFactory) :void
    {
        _pfac = pfac;
        if (level == null) {
            _xml = <platformer><board/></platformer>;
        } else {
            _xml = level;
        }
        if (boardHas("piecenode")) {
            loadPieceTree(_xml.board[0].piecenode[0], _pieceTree);
        } else {
            _pieceTree.push("root");
            _pieceTree.push([ "front" ]);
            _pieceTree.push([ "back" ]);
        }
        if (boardHas("actors")) {
            loadActors(_xml.board[0].actors[0], _actorIns);
        }
    }

    public function getActorIns () :Array
    {
        return _actorIns;
    }

    public function getActors () :Array
    {
        return _actors;
    }

    public function addActor (a :Actor) :void
    {
        trace("adding actor " + a.sprite + " at (" + a.x + ", " + a.y + ")");
        a.id = ++_actorId;
        _actors.push(a);
        sendEvent(ACTOR_ADDED, a, "");
    }

    public function hasActor (a :Actor) :Boolean
    {
        return _actors.indexOf(a) != -1;
    }

    public function addActorIns (a :Actor) :void
    {
        _actorIns.push(a);
        if (_maxId < a.id) {
            _maxId = a.id;
        }
        sendEvent(DYNAMIC_ADDED, a, "root.actors");
    }

    public function updateActorIns (a :Actor) :void
    {
        if (_actorIns.indexOf(a) != -1) {
            sendEvent(ITEM_UPDATED, a, "root.actors");
        }
    }

    public function addShot (s :Shot) :void
    {
        _shots.push(s);
        sendEvent(SHOT_ADDED, s, "");
    }

    public function removeDynamic (d :Dynamic) :void
    {
        var arr :Array = _shots;
        if (d is Actor) {
            arr = _actors;
        }
        var idx :int = arr.indexOf(d);
        if (idx != -1) {
            arr.splice(idx, 1);
        }
        sendEvent(DYNAMIC_REMOVED, d, "");
    }

    public function addPiece (p :Piece, tree :String) :void
    {
        var arr :Array = getGroup(tree);
        if (arr == null) {
            return;
        }
        arr.push(p);
        if (_maxId < p.id) {
            _maxId = p.id;
        }
        sendEvent(PIECE_ADDED, p, tree);
    }

    public function addPieceGroup (tree :String, name :String) :void
    {
        var arr :Array = getGroup(tree);
        if (arr == null) {
            return;
        }
        var group :Array = new Array();
        group.push(name);
        arr.push(group);
        sendEvent(GROUP_ADDED, name, tree);
    }

    public function getItem (name :String, tree :String) :Object
    {
        var arr :Array = getGroup(tree);
        if (arr == null) {
            return null;
        }
        for (var ii :int = 0; ii < arr.length; ii++) {
            if (isItem(arr[ii], name)) {
                return arr[ii];
            }
        }
        return null;

    }

    public function removeItem (name :String, tree :String) :void
    {
        var arr :Array = getGroup(tree);
        if (arr == null) {
            return;
        }
        for (var ii :int = 0; ii < arr.length; ii++) {
            if (isItem(arr[ii], name)) {
                arr.splice(ii--, 1);
            }
        }
        sendEvent(ITEM_REMOVED, name, tree);
    }

    public function moveItemForward (name :String, tree :String) :void
    {
        var arr :Array = getGroup(tree);
        if (arr == null) {
            return;
        }
        var item :Object;
        for (var ii :int = 1; ii < arr.length; ii++) {
            if (isItem(arr[ii], name)) {
                if (ii + 1 < arr.length) {
                    item = arr[ii];
                    arr[ii] = arr[ii + 1];
                    arr[ii + 1] = item;
                }
                break;
            }
        }
        if (item != null) {
            sendEvent(ITEM_FORWARD, name, tree);
        }
    }

    public function moveItemBack (name :String, tree :String) :void
    {
        var arr :Array = getGroup(tree);
        if (arr == null) {
            return;
        }
        var item :Object;
        for (var ii :int = 1; ii < arr.length; ii++) {
            if (isItem(arr[ii], name)) {
                if (ii > 1) {
                    item = arr[ii];
                    arr[ii] = arr[ii - 1];
                    arr[ii - 1] = item;
                }
                break;
            }
        }
        if (item != null) {
            sendEvent(ITEM_BACK, name, tree);
        }
    }

    public function moveItemUp (name :String, tree :String) :void
    {
        var arr :Array = getGroup(tree);
        var up :Array = getGroup(tree.substr(0, tree.lastIndexOf(".")));
        if (arr == null || up == null) {
            return;
        }
        var item :Object;
        for (var ii :int = 1; ii < arr.length; ii++) {
            if (isItem(arr[ii], name)) {
                item = arr[ii];
                arr.splice(ii, 1);
                break;
            }
        }
        if (item != null) {
            var idx :int = up.indexOf(arr);
            up.splice(idx, 0, item);
            sendEvent(ITEM_UP, name, tree);
        }
    }

    public function moveItemDown (name :String, tree :String) :void
    {
        var arr :Array = getGroup(tree);
        if (arr == null) {
            return;
        }
        var item :Object;
        var newarr :Array;
        for (var ii :int = 1; ii < arr.length; ii++) {
            if (isItem(arr[ii], name)) {
                item = arr[ii];
                break;
            }
        }
        if (item == null) {
            return;
        }
        for (var jj :int = ii + 1; jj < arr.length; jj++) {
            if (arr[jj] is Array) {
                newarr = arr[jj];
                break;
            }
        }
        if (newarr != null) {
            arr.splice(ii, 1);
            newarr.splice(1, 0, item);
            sendEvent(ITEM_DOWN, name, tree);
        }
    }

    public function flipPiece (name :String, tree :String) :void
    {
        var arr :Array = getGroup(tree);
        if (arr == null) {
            return;
        }
        for each (var item :Object in arr) {
            if (item is Piece && item.id.toString() == name) {
                var p :Piece = item as Piece;
                p.orient = 1 - p.orient;
                sendEvent(ITEM_UPDATED, p, tree);
            }
        }
    }

    protected function isItem (item :Object, name :String) :Boolean
    {
        return ((item is Piece || item is Dynamic) && item.id.toString() == name) ||
                (item is Array && item[0] == name);
    }

    public function getPieces () :Array
    {
        return _pieceTree;
    }

    protected function getGroup (tree :String) :Array
    {
        tree = tree.replace(/root(\.)*/, "");
        if (tree == "actors") {
            return _actorIns;
        }
        var arr :Array = _pieceTree;
        for each (var name :String in tree.split(".")) {
            if (name == "") {
                continue;
            }
            for each (var node :Object in arr) {
                if (node is Array && node[0] == name) {
                    arr = node as Array;
                    break;
                }
                node = null;
            }
            if (node == null) {
                return null;
            }
        }
        return arr;
    }

    public function getBackgroundXML () :XML
    {
        if (boardHas("background")) {
            return _xml.board[0].background[0];
        }
        return null;
    }

    public function getXML () :XML
    {
        var pieceXML :XML = getPieceTreeXML();
        if (_xml.board[0].piecenode.length() > 0) {
            _xml.board[0].replace("piecenode", pieceXML);
        } else {
            _xml.board[0].appendChild(pieceXML);
        }
        var actorsXML :XML = getActorsXML();
        if (_xml.board[0].actors.length() > 0) {
            _xml.board[0].replace("actors", actorsXML);
        } else {
            _xml.board[0].appendChild(actorsXML);
        }
        return _xml;
    }

    public function getPieceTreeXML () :XML
    {
        return genPieceTreeXML(_pieceTree);
    }

    public function getActorsXML () :XML
    {
        return genActorsXML(_actorIns);
    }

    public function loadActor (xml :XML) :Actor
    {
        var aclass :Class = ClassUtil.getClassByName("piece." + xml.@type);
        if (aclass != null) {
            trace("creating actor: " + xml.@type);
            return new aclass(xml);
        }
        return null;
    }

    protected function loadPieceTree (xml :XML, arr :Array) :void
    {
        arr.push(xml.@name.toString());
        for each (var node :XML in xml.children()) {
            if (node.localName() == "piece") {
                var p :Piece = _pfac.getPiece(node);
                arr.push(p);
                if (_maxId < node.@id) {
                    _maxId = node.@id;
                }
                sendEvent(PIECE_LOADED, p, "");
            } else {
                var child :Array = new Array();
                loadPieceTree(node, child);
                arr.push(child);
            }
        }
    }

    protected function loadActors (xml :XML, arr :Array) :void
    {
        trace("Loading actors");
        for each (var node :XML in xml.children()) {
            arr.push(loadActor(node));
        }
    }

    protected function genPieceTreeXML (pieces :Array) :XML
    {
        var node :XML = <piecenode/>;
        for each (var item :Object in pieces) {
            if (item is Array) {
                node.appendChild(genPieceTreeXML(item as Array));
            } else if (item is Piece) {
                node.appendChild(item.xmlInstance());
            } else {
                node.@name = item;
            }
        }
        return node;
    }

    protected function genActorsXML (actors :Array) :XML
    {
        var node :XML = <actors/>;
        for each (var actor :Actor in actors) {
            node.appendChild(actor.xmlInstance());
        }
        return node;
    }

    public function getMaxId () :int
    {
        return _maxId;
    }

    public function addEventListener (eventName :String, callback :Function) :void
    {
        var _callbacks :Array = _listeners.get(eventName);
        if (_callbacks == null) {
            _listeners.put(eventName, _callbacks = new Array());
        }
        if (_callbacks.indexOf(callback) == -1) {
            _callbacks.push(callback);
        }
    }

    public function removeEventListener (eventName :String, callback :Function) :void
    {
        var _callbacks :Array = _listeners.get(eventName);
        if (_callbacks == null) {
            return;
        }
        var idx :int = _callbacks.indexOf(callback);
        if (idx == -1) {
            return;
        }
        _callbacks.splice(idx, 1);
    }

    protected function sendEvent (eventName :String, ... args) :void
    {
        var _callbacks :Array = _listeners.get(eventName);
        if (_callbacks == null) {
            return;
        }
        _callbacks.forEach(function (callback :*, index :int, array :Array) :void {
            (callback as Function)(args[0], args[1]);
        });
    }

    protected function boardHas (child :String) :Boolean
    {
        return _xml.board[0].child(child).length() > 0;
    }

    /** The XML definition. */
    protected var _xml :XML;

    /** All the pieces on the board. */
    protected var _pieceTree :Array = new Array();
    protected var _maxId :int;
    protected var _actorId :int;

    protected var _actorIns :Array = new Array();
    protected var _actors :Array = new Array();
    protected var _shots :Array = new Array();

    protected var _listeners :HashMap = new HashMap();

    protected var _pfac :PieceFactory;
}
}
