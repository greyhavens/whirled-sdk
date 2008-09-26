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

import mx.containers.HBox;
import mx.controls.Text;

import com.threerings.flex.CommandButton;

public class FeedbackDialog extends LightweightCenteredDialog
{
    public function FeedbackDialog (feedback :String, error :Boolean = false)
    {
        _feedback = feedback;

        width = 300;
        height = 150;
        title = error ? "Error!" : "Feedback";
        setStyle("backgroundColor", error ? 0xFFAAAA : 0xAAFFAA);
    }

    override protected function createChildren () :void
    {
        super.createChildren();

        var labelBox :HBox = new HBox();
        labelBox.percentWidth = 100;
        labelBox.setStyle("horizontalAlign", "center");
        labelBox.setStyle("paddingTop", 5);
        labelBox.setStyle("paddingBottom", 5);
        labelBox.setStyle("paddingLeft", 5);
        labelBox.setStyle("paddingRight", 5);
        addChild(labelBox);
        var label :Text = new Text();
        label.text = _feedback;
        labelBox.addChild(label);

        var spacerBox :HBox = new HBox();
        spacerBox.percentWidth = 100;
        spacerBox.percentHeight = 100;
        addChild(spacerBox);

        var buttonBox :HBox = new HBox();
        buttonBox.percentWidth = 100;
        buttonBox.setStyle("horizontalAlign", "center");
        buttonBox.setStyle("paddingTop", 5);
        buttonBox.setStyle("paddingBottom", 5);
        buttonBox.setStyle("paddingLeft", 5);
        buttonBox.setStyle("paddingRight", 5);
        addChild(buttonBox);
        buttonBox.addChild(new CommandButton("Dismiss", close));
    }

    protected var _feedback :String;
}
}
