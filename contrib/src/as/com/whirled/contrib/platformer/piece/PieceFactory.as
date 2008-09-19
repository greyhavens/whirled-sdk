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

package com.whirled.contrib.platformer.piece {

import flash.system.ApplicationDomain;

import com.threerings.util.HashMap;
import com.threerings.util.ClassUtil;

public class PieceFactory
{
    public static const PIECE_ADDED :String = "added";
    public static const PIECE_REMOVED :String = "removed";
    public static const PIECE_UPDATED :String = "updated";

    public function PieceFactory (xml :XML) :void
    {
        if (xml != null) {
            for each (var pset :XML in xml.pieceset) {
                for each (var pdef :XML in pset.piecedef) {
                    _pieceMap.put(pdef.@type.toString(), pdef);
                }
            }
        }
        initPieceClasses();
    }

    public function initPieceClasses () :void
    {
        addPieceClass(new Piece(), true);
        addPieceClass(new BoundedPiece());
    }

    /**
     * Returns an array of fully qualified class names for piece classes.
     */
    public function getPieceClasses () :Array
    {
        return _pieceClasses.values();
    }

    /**
     * Returns an array of just the class name for piece classes.
     */
    public function getShortPieceClasses () :Array
    {
        return _pieceClasses.keys();
    }

    /**
     * Given the short classname provided by getShortPieceClasses(), returns the cooresponding
     * fully qualified class name.
     */
    public function getClassName (shortName :String) :String
    {
        return _pieceClasses.get(shortName) as String;
    }

    public function getPiece (xml :XML) :Piece
    {
        var pdef :XML = _pieceMap.get(xml.@type.toString());
        if (pdef == null) {
            return null;
        }
        var cname :String = pdef.@cname;
        if (cname == null || !ApplicationDomain.currentDomain.hasDefinition(cname)) {
            cname = _defaultClass;
        }
        if (cname == null) {
            throw new Error("Unable to instantiate piece");
        }
        var cdef :Class = ApplicationDomain.currentDomain.getDefinition(cname) as Class;
        return new cdef(pdef, xml) as Piece;
    }

    public function newPiece (p :Piece) :void
    {
        var pdef :XML = p.xmlDef();
        _pieceMap.put(pdef.@type.toString(), pdef);
        sendEvent(PIECE_ADDED, pdef.@type.toString(), pdef);
    }

    public function updatePiece (oldp :Piece, newp :Piece) :void
    {
        _pieceMap.remove(oldp.type);
        _pieceMap.put(newp.type, newp.xmlDef());
        if (oldp.type != newp.type) {
            sendEvent(PIECE_REMOVED, oldp.type, oldp.xmlDef());
            sendEvent(PIECE_ADDED, newp.type, newp.xmlDef());
        } else {
            sendEvent(PIECE_UPDATED, newp.type, newp.xmlDef());
        }
    }

    public function deletePiece (p :Piece) :void
    {
        _pieceMap.remove(p.type);
        sendEvent(PIECE_REMOVED, p.type, p.xmlDef());
    }

    public function getPieceDefs () :Array
    {
        return _pieceMap.values();
    }

    public function toXML () :XML
    {
        var xml :XML = <platformer>
            <pieceset/>
        </platformer>;
        for each (var pdef :XML in getPieceDefs()) {
            xml.pieceset[0].appendChild(pdef);
        }
        return xml;
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

    protected function sendEvent (eventName :String, type :String, xmldef :XML) :void
    {
        var _callbacks :Array = _listeners.get(eventName);
        if (_callbacks == null) {
            return;
        }
        _callbacks.forEach(function (callback :*, index :int, array :Array) :void {
            (callback as Function)(type, xmldef);
        });
    }

    protected function addPieceClass (piece :Piece, isDefault :Boolean = false) :void
    {
        var sname :String = ClassUtil.tinyClassName(piece);
        var cname :String = ClassUtil.getClassName(piece);
        _pieceClasses.put(sname, cname);
        if (isDefault) {
            _defaultClass = cname;
        }
    }

    protected var _pieceMap :HashMap = new HashMap();
    protected var _listeners :HashMap = new HashMap();
    protected var _pieceClasses :HashMap = new HashMap();
    protected var _defaultClass :String;
}
}
