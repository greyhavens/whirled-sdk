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

import flash.events.Event;

import mx.core.Container;
import mx.containers.HBox;
import mx.containers.Panel;
import mx.containers.TabNavigator;
import mx.containers.VBox;
import mx.controls.TextArea;
import mx.events.IndexChangedEvent;

import flash.net.URLLoader;
import flash.net.URLRequest;

import com.whirled.contrib.platformer.piece.PieceFactory;

/**
 * A piece editor for platformer games.  The use of this piece editor requires the inclusion of
 * libraries from FlexBuilder 3 Pro for Flex Data Visualization.
 */
public class PieceEditor extends Panel
{
    public function PieceEditor ()
    {
        title = "Platformer Piece Editor";
        width = 940;
        height = 800;
        setStyle("paddingTop", 0);
        setStyle("paddingBottom", 0);
        setStyle("paddingLeft", 0);
        setStyle("paddingRight", 0);
    }

    /**
     * Must be called to set up loading the XML for this piece editor
     */
    public function setXmlPaths (piecesXmlPath :String) :void
    {
        if (piecesXmlPath == null || piecesXmlPath == "") {
            _piecesLoaded = true;
            addEditView();
            return;
        }

        piecesXmlPath = piecesXmlPath.replace(/:/, "|");
        piecesXmlPath = piecesXmlPath.replace(/\\/g, "/");
        _piecesLoader = new URLLoader();
        _piecesLoader.addEventListener(Event.COMPLETE, function (event :Event) :void {
            _piecesLoaded = true;
            addEditView();
        });
        _piecesLoader.load(new URLRequest("file://" + piecesXmlPath));
    }

    /**
     * Called externally when PieceSpriteFactory is initialized.
     */
    public function pieceFactoryInitialized () :void
    {
        _factoryInitialized = true;
        addEditView();
    }

    public function setPieceFactoryClass (pfClass :Class) :void
    {
        _pieceFactoryClass = pfClass;
    }

    override protected function createChildren () :void
    {
        super.createChildren();

        _tabs = new TabNavigator();
        _tabs.percentWidth = 100;
        _tabs.percentHeight = 100;
        _tabs.addEventListener(IndexChangedEvent.CHANGE, function (...ignored) :void {
            tabChanged(_tabs.selectedChild);
        });
        addChild(_tabs);
    }

    protected function addEditView () :void
    {
        if (!_piecesLoaded || !_factoryInitialized) {
            return;
        }

        var xmlPieces :XML = (_piecesLoader == null ? null : new XML(_piecesLoader.data));
        _editView = new PieceEditView(new _pieceFactoryClass(xmlPieces));
        _editView.label = "Edit Piece";
        _tabs.addChild(_editView);

        _xmlCode = new VBox();
        _xmlCode.label = "XML Code";
        _xmlCode.percentWidth = 100;
        _xmlCode.percentHeight = 100;
        _tabs.addChild(_xmlCode);
        _codeArea = new TextArea();
        _codeArea.percentWidth = 100;
        _codeArea.percentHeight = 100;
        _codeArea.editable = false;
        _codeArea.setStyle("fontFamily", "Sans");
        _codeArea.setStyle("fontSize", "12");
        _xmlCode.addChild(_codeArea);
    }

    protected function tabChanged (selected :Container) :void
    {
        if (selected == _xmlCode) {
            _codeArea.text = _editView.getXML().toXMLString();
        }
    }

    protected var _tabs :TabNavigator;
    protected var _xmlCode :VBox;
    protected var _codeArea :TextArea;
    protected var _editView :PieceEditView;
    protected var _piecesLoader :URLLoader;
    protected var _piecesLoaded :Boolean;
    protected var _factoryInitialized :Boolean = false;
    protected var _pieceFactoryClass :Class = PieceFactory;
}
}
