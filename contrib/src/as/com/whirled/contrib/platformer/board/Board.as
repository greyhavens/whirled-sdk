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
import com.threerings.util.Map;
import com.threerings.util.Maps;

import com.whirled.contrib.platformer.PlatformerContext;
import com.whirled.contrib.platformer.piece.Actor;
import com.whirled.contrib.platformer.piece.Dynamic;
import com.whirled.contrib.platformer.piece.Piece;
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

    public static const ACTORS :String = "actors";
    public static const SPAWNERS :String = "spawners";
    public static const PLATFORMS :String = "platforms";
    public static const GENERICS :String = "generics";
    public static const GATES :String = "gates";

    public static const TOP_BOUND :int = 0;
    public static const RIGHT_BOUND :int = 1;
    public static const BOTTOM_BOUND :int = 2;
    public static const LEFT_BOUND :int = 3;

    public static const DEBUG :Boolean = false;

    public static function loadDynamic (xml :XML) :Dynamic
    {
        return PlatformerContext.dfac.loadDynamic(xml);
    }

    public function Board () :void
    {
        _groupNames = new Array();
        _groupNames.push(ACTORS);
        _groupNames.push(SPAWNERS);
        _groupNames.push(PLATFORMS);
        _groupNames.push(GENERICS);
        _groupNames.push(GATES);
    }

    public function loadFromXML (level :XML) :void
    {
        if (level == null) {
            _xml = <platformer><board/></platformer>;
        } else {
            _xml = level;
        }
        setName(_xml.board[0].@name);
        if (boardHas("piecenode")) {
            loadPieceTree(_xml.board[0].piecenode[0], _pieceTree);
        } else {
            _pieceTree.push("root");
            _pieceTree.push([ "front" ]);
            _pieceTree.push([ "back" ]);
        }
        for each (var name :String in _groupNames) {
            _dynamicIns[name] = new Object();
            if (boardHas(name)) {
                loadDynamics(_xml.board[0][name][0], _dynamicIns[name]);
            }
        }
    }

    public function setName (name :String) :void
    {
        _name = name;
    }

    public function getName () :String
    {
        return _name;
    }

    public function getGroupNames () :Array
    {
        return _groupNames;
    }

    public function getDynamicIns (group :String = null) :Object
    {
        if (group == null) {
            return _globalDynamicIns;
        }
        return _dynamicIns[group];
    }

    public function getDynamicInsById (id :int) :Dynamic
    {
        return _globalDynamicIns[id];
    }

    public function getActors () :Object
    {
        return _actors;
    }

    public function getActor (id :int) :Actor
    {
        if (_actors[id] != undefined) {
            return _actors[id];
        }
        return _dynamicIns[Board.ACTORS][id];
    }

    public function getDynamics () :Object
    {
        return _dynamics;
    }

    public function getDynamic (id :int) :Dynamic
    {
        return _dynamics[id];
    }

    public function addActor (a :Actor) :void
    {
        if (a.id <= 0) {
            a.id = ++_maxId;
        }
        _actors[a.id] = a;
        //_actors.push(a);
        debug("adding actor " + a.sprite + "(" + a.id + ") at (" + a.x + ", " + a.y + ")");
        sendEvent(ACTOR_ADDED, a, "");
    }

    public function addDynamic (d :Dynamic) :void
    {
        if (d.id <= 0) {
            d.id = ++_maxId;
        }
        _dynamics[d.id] = d;
        //_dynamics.push(d);
        debug("adding dynamic " + d.id + " at (" + d.x + ", " + d.y + ")");
        sendEvent(DYNAMIC_ADDED, d, "");
    }

    public function hasActor (a :Actor) :Boolean
    {
        return _actors[a.id] != undefined;
        //return _actors.indexOf(a) != -1;
    }

    public function hasDynamic (d :Dynamic) :Boolean
    {
        return _dynamics[d.id] != undefined;
    }

    public function addDynamicIns (d :Dynamic, group :String) :void
    {
        setDynamicIns(group, d);
        //_dynamicIns[group].push(d);
        adjustMaxId(d);
        sendEvent(DYNAMIC_ADDED, d, "root." + group);
    }

    public function updateDynamicIns (d :Dynamic, group :String) :void
    {
        setDynamicIns(group, d);
        sendEvent(ITEM_UPDATED, d, "root." + group);
    }

    public function addShot (s :Shot) :void
    {
        s.id = ++_shotId;
        _shots[s.id] = s;
        //_shots.push(s);
        sendEvent(SHOT_ADDED, s, "");
    }

    public function removeDynamic (d :Dynamic) :void
    {
        var arr :Object = _dynamics;
        if (d is Actor) {
            arr = _actors;
        } else if (d is Shot) {
            arr = _shots;
        } else {
            debug("removing dynamic " + d.id);
        }
        delete arr[d.id];
        /*
        var idx :int = arr.indexOf(d);
        if (idx != -1) {
            arr.splice(idx, 1);
        }
        */
        sendEvent(DYNAMIC_REMOVED, d, "");
    }

    public function addPiece (p :Piece, tree :String) :void
    {
        var arr :Array = getGroup(tree) as Array;
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
        var arr :Array = getGroup(tree) as Array;
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
        var arr :Object = getGroup(tree);
        if (arr == null) {
            return null;
        } else if (arr is Array) {
            for (var ii :int = 0; ii < arr.length; ii++) {
                if (isItem(arr[ii], name)) {
                    return arr[ii];
                }
            }
        } else {
           return arr[name];
        }
        return null;

    }

    public function removeItem (name :String, tree :String) :void
    {
        var arr :Object = getGroup(tree);
        if (arr == null) {
            return;
        } else if (arr is Array) {
            for (var ii :int = 0; ii < arr.length; ii++) {
                if (isItem(arr[ii], name)) {
                    arr.splice(ii--, 1);
                }
            }
        } else {
            delete arr[name];
            delete _globalDynamicIns[name];
        }
        sendEvent(ITEM_REMOVED, name, tree);
    }

    public function moveItemForward (name :String, tree :String) :void
    {
        var arr :Array = getGroup(tree) as Array;
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
        var arr :Array = getGroup(tree) as Array;
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
        var arr :Array = getGroup(tree) as Array;
        var up :Array = getGroup(tree.substr(0, tree.lastIndexOf("."))) as Array;
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
        var arr :Array = getGroup(tree) as Array;
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
        var arr :Array = getGroup(tree) as Array;
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

    public function updatePiece (name :String, tree :String, xml :XML) :void
    {
        var arr :Array = getGroup(tree) as Array;
        if (arr == null) {
            return;
        }
        for each (var item :Object in arr) {
            if (item is Piece && item.id.toString() == name) {
                var p :Piece = item as Piece;
                p.setXMLEditables(xml);
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

    protected function getGroup (tree :String) :Object
    {
        tree = tree.replace(/root(\.)*/, "");
        if (_dynamicIns[tree] != null) {
            return _dynamicIns[tree];
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

    public function getEventXML () :XML
    {
        if (boardHas("events")) {
            return _xml.board[0].events[0];
        }
        return null;
    }

    public function getXML () :XML
    {
        _xml.board[0].@name = getName();
        addOrReplaceXML(_xml.board[0], "piecenode", getPieceTreeXML());
        for each (var group :String in getGroupNames()) {
            addOrReplaceXML(_xml.board[0], group, getDynamicsXML(group));
        }
        return _xml;
    }

    public function getPieceTreeXML () :XML
    {
        return genPieceTreeXML(_pieceTree);
    }

    public function getDynamicsXML (group :String) :XML
    {
        return genDynamicsXML(_dynamicIns[group], group);
    }

    public function setBound (idx :int, bound :int) :void
    {
        _bound[idx] = bound;
    }

    public function getBound (idx :int) :int
    {
        return _bound[idx];
    }

    protected function loadPieceTree (xml :XML, arr :Array) :void
    {
        arr.push(xml.@name.toString());
        for each (var node :XML in xml.children()) {
            if (node.localName() == "piece") {
                var p :Piece = PlatformerContext.pfac.getPiece(node);
                if (p == null) {
                    debug("failed to load piece: " + node.toXMLString());
                } else {
                    arr.push(p);
                    if (_maxId < p.id) {
                        _maxId = p.id;
                    }
                    sendEvent(PIECE_LOADED, p, "");
                }
            } else {
                var child :Array = new Array();
                loadPieceTree(node, child);
                arr.push(child);
            }
        }
    }

    protected function loadDynamics (xml :XML, arr :Object) :void
    {
        debug("Loading dynamics");
        for each (var node :XML in xml.children()) {
            var d :Dynamic = loadDynamic(node);
            if (d != null) {
                adjustMaxId(d);
                arr[d.id] = d;
                _globalDynamicIns[d.id] = d;
                //arr.push(d);
            }
        }
    }

    protected function loadCoords (xml :XML, arr :Array) :void
    {
        for each (var node :XML in xml.children()) {
            arr.push([ node.@x, node.@y ]);
        }
    }

    protected function addOrReplaceXML (source:XML, nodename :String, node :XML) :void
    {
        if (source.child(nodename).length() > 0) {
            source.replace(nodename, node);
        } else {
            source.appendChild(node);
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

    protected function genDynamicsXML (dynamics :Object, nodename :String) :XML
    {
        var node :XML = new XML("<" + nodename + "/>");
        for each (var dyn :Dynamic in dynamics) {
            node.appendChild(dyn.xmlInstance());
        }
        return node;
    }

    public function getMaxId () :int
    {
        return _maxId;
    }

    public function reserveId () :int
    {
        return ++_maxId;
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

    protected function adjustMaxId (d :Dynamic) :void
    {
        if (_maxId < d.id) {
            _maxId = d.id;
        }
    }

    protected function setDynamicIns (group :String, d :Dynamic) :void
    {
        _dynamicIns[group][d.id] = d;
        _globalDynamicIns[d.id] = d;
    }

    protected static function debug (msg :String) :void
    {
        if (DEBUG) {
            trace(msg);
        }
    }

    /** The XML definition. */
    protected var _xml :XML;

    /** All the pieces on the board. */
    protected var _pieceTree :Array = new Array();
    protected var _maxId :int;
    protected var _shotId :int = SHOT_BASE;
    protected var _name :String;

    protected var _actors :Object = new Object();
    protected var _dynamics :Object = new Object();
    protected var _dynamicIns :Object = new Object();
    protected var _globalDynamicIns :Object = new Object();
    protected var _shots :Object = new Object();
    protected var _bound :Array = new Array();

    protected var _listeners :Map = Maps.newMapOf(String);

    protected var _groupNames :Array;

    protected static const SHOT_BASE :int = 1000000;
    protected static const LOCAL_BASE :int = 10000;
}
}
