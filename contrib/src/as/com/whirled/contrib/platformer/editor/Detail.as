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

import mx.containers.Box;
import mx.containers.HBox;
import mx.core.UIComponent;
import mx.controls.ComboBox;
import mx.controls.TextInput;
import mx.controls.Label;
import mx.utils.ArrayUtil;

public class Detail
{
    public var name :String;

    public function Detail (attr :XML = null)
    {
        if (attr != null) {
            this.name = attr.name();
        }
    }

    public function createBox () :Box
    {
        var box :HBox = new HBox();
        var label :Label = new Label();
        label.text = name + ":";
        box.addChild(label);
        box.addChild(input());
        return box;
    }

    public function setData (defxml :XML) :void
    {
    }

    protected function input () :UIComponent
    {
        return new Label();
    }
}
}
