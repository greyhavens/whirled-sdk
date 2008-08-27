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
import mx.containers.VBox;
import mx.controls.Button;
import mx.events.FlexEvent;

public class BoundsDetail extends Detail
{
    public function BoundsDetail (attr :XML)
    {
        super(attr);
        for each (var bdef :XML in attr.bound) {
            _bounds.push(new BoundDetail(bdef));
        }
    }

    public override function createBox () :Box
    {
        var box :VBox = new VBox();
        _bbox = new VBox();
        for each (var bound :BoundDetail in _bounds) {
            _bbox.addChild(bound.createBox());
        }
        box.addChild(_bbox);
        var button :Button = new Button();
        button.label = "+";
        button.addEventListener(FlexEvent.BUTTON_DOWN, addBound);
        box.addChild(button);
        return box;
    }

    public override function setData (defxml :XML) :void
    {
        var xml :XML = <bounds/>;
        for each (var bound :BoundDetail in _bounds) {
            bound.setData(xml);
        }
        defxml.appendChild(xml);
    }

    protected function addBound (event :FlexEvent) :void
    {
        var bound :BoundDetail = new BoundDetail();
        _bounds.push(bound);
        _bbox.addChild(bound.createBox());
    }

    protected var _bounds :Array = new Array();
    protected var _bbox :VBox;
}
}
