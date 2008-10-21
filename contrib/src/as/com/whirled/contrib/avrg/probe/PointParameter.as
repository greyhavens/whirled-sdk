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

package com.whirled.contrib.avrg.probe {

import flash.geom.Point;
import com.threerings.util.StringUtil;

/**
 * Parameter type to be used when a <code>Point</code> is expected. Parsing is very simple and uses
 * the text before the first comma as the x value and after the comma as the y value.
 */
public class PointParameter extends Parameter
{
    /**
     * Creates a new point parameter.
     * @param name the name of the parameter
     * @param flash optional flags to pass to the superclass
     */
    public function PointParameter(name :String, flags :uint=0)
    {
        super(name, Point, flags);
    }

    /** @inheritDoc */
    // from Parameter
    override public function parse (input :String) :Object
    {
        var comma :int = input.indexOf(",");
        if (comma < 1 || comma != input.lastIndexOf(",")) {
            throw new Error("Expected two number separated by one comma");
        }
        var x :Number = StringUtil.parseNumber(trim(input.substr(0, comma)));
        var y :Number = StringUtil.parseNumber(trim(input.substr(comma + 1)));
        return new Point(x, y);
    }
}

}
