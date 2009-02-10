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

import flash.display.Sprite
import flash.display.Shape;

import flash.system.ApplicationDomain;

import mx.core.FlexSprite;
import mx.controls.Button;
import mx.controls.ComboBox;
import mx.controls.HRule;
import mx.controls.Label;
import mx.controls.TextInput;
import mx.containers.VBox;
import mx.containers.HBox;
import mx.containers.Canvas;
import mx.core.ScrollPolicy;

import mx.events.FlexEvent;

import com.threerings.util.HashMap;

import com.whirled.contrib.platformer.piece.Piece;
import com.whirled.contrib.platformer.piece.PieceFactory;

import com.whirled.contrib.platformer.util.Metrics;

public class PieceEditDetails extends Canvas
{
    public function PieceEditDetails (pfac :PieceFactory, editSprite :PieceEditSprite)
    {
        initDetails();
        _pfac = pfac;
        _editSprite = editSprite;
        width = 210;
        horizontalScrollPolicy = ScrollPolicy.OFF;
        height = Metrics.DISPLAY_HEIGHT;
        var vbox :VBox = new VBox();
        var hbox :HBox = new HBox();
        var label :Label = new Label();
        label.text = "Type:";
        hbox.addChild(label);
        _createType = new TextInput();
        _createType.width = 150;
        hbox.addChild(_createType);
        vbox.addChild(hbox);
        hbox = new HBox();
        label = new Label();
        label.text = "Class:";
        hbox.addChild(label);
        _createClass = new ComboBox();
        _createClass.width = 150;
        _createClass.dataProvider = pfac.getShortPieceClasses();
        hbox.addChild(_createClass);
        vbox.addChild(hbox);
        var button :Button = new Button();
        button.label = "Create";
        button.addEventListener(FlexEvent.BUTTON_DOWN, createPiece);
        vbox.addChild(button);
        vbox.addChild(new HRule());
        vbox.addChild(_detailsBox = new VBox());
        addChild(vbox);
        vbox.x = 0;
        vbox.y = 0;
    }

    public function setPiece (type :String, p :Piece = null) :void
    {
        if (type != null) {
            _createType.text = type;
        }
        _p = p;
        _detailsBox.removeAllChildren();
        if (p != null) {
            _details = new Array();
            var xmlDef :XML = p.xmlDef();
            for each (var attr :XML in xmlDef.attributes()) {
                var detail :Detail = getDetail(attr);
                _details.push(detail);
                _detailsBox.addChild(detail.createBox());
            }
            for each (var child :XML in xmlDef.children()) {
                detail = getDetail(child);
                _details.push(detail);
                _detailsBox.addChild(detail.createBox());
            }
            var hbox :HBox = new HBox();
            var button :Button = new Button();
            button.label = "Update";
            button.addEventListener(FlexEvent.BUTTON_DOWN, updatePiece);
            hbox.addChild(button);
            button = new Button();
            button.label = "Delete";
            button.addEventListener(FlexEvent.BUTTON_DOWN, deletePiece);
            hbox.addChild(button);
            _detailsBox.addChild(hbox);
        }
    }

    public function updatePiece (...ignored) :void
    {
        var defxml :XML = <piecedef/>;
        for each (var detail :Detail in _details) {
            detail.setData(defxml);
        }
        var cname :String = defxml.@cname;
        if (cname == null || !ApplicationDomain.currentDomain.hasDefinition(cname)) {
            return;
        }
        var cdef :Class = ApplicationDomain.currentDomain.getDefinition(cname) as Class;
        var p :Piece = new cdef(defxml) as Piece;
        _pfac.updatePiece(_p, p);
    }

    public function getCurrentPiece () :Piece
    {
        return _p;
    }

    protected function createPiece (event :FlexEvent) :void
    {
        var cname :String = _pfac.getClassName(_createClass.selectedLabel);
        if (!ApplicationDomain.currentDomain.hasDefinition(cname)) {
            return;
        }
        var cdef :Class = ApplicationDomain.currentDomain.getDefinition(cname) as Class;
        var p :Piece = new cdef() as Piece;
        p.type = _createType.text;
        _pfac.newPiece(p);
    }

    protected function deletePiece (...ignored) :void
    {
        _pfac.deletePiece(_p);
    }

    protected function getDetail (attr :XML) :Detail
    {
        var name :String = attr.name().toString();
        var dfunc :Function = _detailTypes.get(name);
        if (dfunc != null) {
            return dfunc(attr) as Detail
        }
        if (name.indexOf("nudge") == 0) {
            return new CheckDetail(attr);
        }
        return new TextDetail(attr);
    }

    protected function initDetails () :void
    {
        if (_detailTypes != null) {
            return;
        }
        _detailTypes = new HashMap();
        _detailTypes.put("cname", function (attr :XML) :Detail {
            return new ComboDetail(
                attr, _pfac.getShortPieceClasses(), function (option :String) :String {
                    return _pfac.getClassName(option);
                }, function (value :String) :String {
                    var dex :int = value.lastIndexOf(".");
                    return value.substring(dex + 1); // works even if dex is -1
                });
        });
        var thisDetail :PieceEditDetails = this;
        _detailTypes.put("bounds", function (attr :XML) :Detail {
            return new BoundsDetail(attr, _editSprite, thisDetail);
        });
    }

    protected var _createType :TextInput;
    protected var _createClass :ComboBox;

    protected var _detailsBox :VBox;

    protected var _details :Array;

    protected var _pfac :PieceFactory;
    protected var _editSprite :PieceEditSprite;

    protected var _p :Piece;

    protected static var _detailTypes :HashMap;
}
}
