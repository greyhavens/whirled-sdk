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

import mx.core.UIComponent;
import mx.controls.ComboBox;
import mx.utils.ArrayUtil;

public class ComboDetail extends Detail
{
    public function ComboDetail (attr :XML, options :Array)
    {
        super(attr);
        _combo = new ComboBox();
        _combo.dataProvider = options;
        _combo.selectedIndex = ArrayUtil.getItemIndex(attr.toString(), options);
        _combo.width = 150;
    }

    public override function setData (defxml :XML) :void
    {
        defxml.@[name] = _combo.selectedLabel;
    }

    protected override function input () :UIComponent
    {
        return _combo;
    }

    protected var _combo :ComboBox;
}
}
