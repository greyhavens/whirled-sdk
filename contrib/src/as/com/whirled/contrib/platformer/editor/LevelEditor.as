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

import com.whirled.contrib.platformer.board.Board;
import com.whirled.contrib.platformer.editor.EditView;
import com.whirled.contrib.platformer.piece.PieceFactory;

/**
 * A level editor for platformer games.  The use of this level editor requires the inclusion of
 * libraries from FlexBuilder 3 Pro for Flex Data Visualization.
 */
public class LevelEditor extends Panel
{
    public function LevelEditor ()
    {
        title = "Platformer Level Editor";
        percentHeight = 100;
        percentWidth = 100;
        setStyle("paddingTop", 0);
        setStyle("paddingBottom", 0);
        setStyle("paddingLeft", 0);
        setStyle("paddingRight", 0);
    }

    /**
     * Set the board to be used in the level editor.
     */
    public function setBoard (board :Board) :void
    {
        _board = board;
    }

    /**
     * Must be called to set up loading the XML for this level editor.
     */
    public function setXmlPaths (piecesXmlPath :String, dynamicsXmlPath :String,
        levelXmlPath :String) :void
    {
        piecesXmlPath = piecesXmlPath.replace(/:/, "|");
        piecesXmlPath = piecesXmlPath.replace(/\\/g, "/");
        _piecesLoader = new URLLoader();
        _piecesLoader.addEventListener(Event.COMPLETE,
            function (event :Event) :void {
                _piecesLoaded = true;
                addEditView();
            });
        _piecesLoader.load(new URLRequest("file://" + piecesXmlPath));

        dynamicsXmlPath = dynamicsXmlPath.replace(/:/, "|");
        dynamicsXmlPath = dynamicsXmlPath.replace(/\\/g, "/");
        if (dynamicsXmlPath == null || dynamicsXmlPath == "") {
            _dynamicsLoaded = true;
            addEditView();
        } else {
            _dynamicsLoader = new URLLoader();
            _dynamicsLoader.addEventListener(Event.COMPLETE,
                function (event :Event) :void {
                    _dynamicsLoaded = true;
                    addEditView();
                });
            _dynamicsLoader.load(new URLRequest("file://" + dynamicsXmlPath));
        }

        levelXmlPath = levelXmlPath.replace(/:/, "|");
        levelXmlPath = levelXmlPath.replace(/\\/g, "/");
        if (levelXmlPath == null || levelXmlPath == "") {
            _levelLoaded = true;
            addEditView();
        } else {
            _levelLoader = new URLLoader();
            _levelLoader.addEventListener(Event.COMPLETE,
                function (event :Event) :void {
                    _levelLoaded = true;
                    addEditView();
                });
            _levelLoader.load(new URLRequest("file://" + levelXmlPath));
        }
    }

    /**
     * Called externally when PieceSpriteFactory is initialized
     */
    public function pieceFactoryInitialized () :void
    {
        _factoryInitialized = true;
        addEditView();
    }

    override protected function createChildren () :void
    {
        super.createChildren();

        var tabs :TabNavigator = new TabNavigator();
        tabs.percentWidth = 100;
        tabs.percentHeight = 100;
        tabs.addEventListener(IndexChangedEvent.CHANGE, function (...ignored) :void {
            tabChanged(tabs.selectedChild);
        });
        var editBox :HBox = new HBox();
        editBox.percentWidth = 100;
        editBox.label = "Edit Level";
        editBox.addChild(_levelEdit = new FocusContainer());
        _levelEdit.width = 900;
        _levelEdit.height = 700;
        tabs.addChild(editBox);
        _xmlCode = new VBox();
        _xmlCode.label = "XML Code";
        _xmlCode.percentWidth = 100;
        _xmlCode.percentHeight = 100;
        tabs.addChild(_xmlCode);
        addChild(tabs);
    }

    protected function addEditView () :void
    {
        if (!_levelLoaded || !_piecesLoaded || !_dynamicsLoaded || !_factoryInitialized) {
            return;
        }
        _codeArea = new TextArea();
        _codeArea.percentWidth = 100;
        _codeArea.percentHeight = 100;
        _codeArea.editable = false;
        _codeArea.setStyle("fontFamily", "Sans");
        _codeArea.setStyle("fontSize", "12");
        _xmlCode.addChild(_codeArea);

        var xmlPieces :XML = new XML(_piecesLoader.data);
        var xmlLevel :XML = (_levelLoader == null ? null : new XML(_levelLoader.data));
        var xmlDynamics :XML =
            (_dynamicsLoader == null ? <dynamics/> : new XML(_dynamicsLoader.data));

        _levelEdit.rawChildren.addChild(_editView = new EditView(
            new PieceFactory(xmlPieces), xmlDynamics, xmlLevel, _board));
    }

    protected function tabChanged (selected :Container) :void
    {
        if (selected == _xmlCode) {
            _codeArea.text = _editView.getXML().toXMLString();
        }
    }

    protected var _codeArea :TextArea;
    protected var _editView :EditView;
    protected var _piecesLoader :URLLoader;
    protected var _levelLoader :URLLoader;
    protected var _dynamicsLoader :URLLoader;
    protected var _piecesLoaded :Boolean;
    protected var _levelLoaded :Boolean;
    protected var _dynamicsLoaded :Boolean;
    protected var _levelEdit :FocusContainer;
    protected var _xmlCode :VBox;
    protected var _factoryInitialized :Boolean = false;
    protected var _board :Board;
}
}
