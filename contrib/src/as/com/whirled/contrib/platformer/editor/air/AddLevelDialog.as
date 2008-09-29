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

package com.whirled.contrib.platformer.editor.air {

import flash.events.Event;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

import mx.containers.HBox;
import mx.containers.VBox;
import mx.controls.Label;
import mx.core.UIComponent;

import com.threerings.flex.CommandButton;

public class AddLevelDialog extends LightweightCenteredDialog
{
    public function AddLevelDialog (projectFile :File, callback :Function)
    {
        _projectFile = projectFile;
        _callback = callback;

        width = 600;
        height = 160;
        title = "Add Level to Project";
        setStyle("backgroundColor", "white");
    }

    override protected function createChildren () :void
    {
        super.createChildren();

        // Windows use vertical layout by default, but VBox gives us some extra stuff, like padding
        var container :VBox = new VBox();
        container.percentWidth = 100;
        container.percentHeight = 100;
        setStyles(container, -1, 10);
        addChild(container);

        var nameRow :HBox = new HBox();
        setStyles(nameRow, 10, 5);
        var nameLabel :Label = new Label();
        nameLabel.text = "Level Name:";
        nameLabel.setStyle("fontWeight", "bold");
        nameRow.addChild(nameLabel);
        container.addChild(nameLabel);
        
        container.addChild(_levelXmlRow = new EditorFileRow(
            "Level XML", "xml", true, _projectFile.parent.clone(), _projectFile, this));
        _levelXmlRow.addEventListener(EditorFileRow.SELECTED, selectedFile);

        var dialogButtons :HBox = new HBox(); 
        dialogButtons.percentWidth = 100;
        setStyles(dialogButtons, 10, 5);
        var spacer :HBox = new HBox();
        spacer.percentWidth = 100;
        dialogButtons.addChild(spacer);
        dialogButtons.addChild(new CommandButton("Cancel", close));
        dialogButtons.addChild(new CommandButton("Add Level", handleSave));
        container.addChild(dialogButtons);
    }

    protected function setStyles (component :UIComponent, gap :int, padding :int) :void
    {
        if (gap >= 0) {
            component.setStyle("horizontalGap", gap);
        }

        if (padding >= 0) {
            component.setStyle("paddingTop", padding);
            component.setStyle("paddingBottom", padding);
            component.setStyle("paddingLeft", padding);
            component.setStyle("paddingRight", padding);
        }
    }

    protected function selectedFile (event :Event) :void
    {
    }

    protected function handleSave () :void
    {
    }

    protected var _projectFile :File;
    protected var _callback :Function;
    protected var _levelXmlRow :EditorFileRow;
}
}
