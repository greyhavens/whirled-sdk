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
// $Id: PointParameter.as 6232 2008-10-21 15:10:33Z jamie $

package com.whirled.contrib.avrg.probe {

import flash.geom.Rectangle;

/**
 * Parameter type to be used when a <code>Rectangle</code> is expected.
 * Paramters are parsed as comma-separated.
 */
public class RectangleParameter extends Parameter
{
    /**
     * Creates a new rectangle parameter.
     * @param name the name of the parameter
     * @param flash optional flags to pass to the superclass
     */
    public function RectangleParameter (name :String, flags :uint = 0)
    {
        super(name, Rectangle, flags);
    }

    /** @inheritDoc */
    // from Parameter
    override public function parse (input :String) :Object
    {
        if (input == "null") {
            return null;
        }
        var params :Array = new ArrayParameter("", Number).parse(input) as Array;
        if (params.length != 4) {
            throw new Error("Expected four numbers separated by commas");
        }
        return new Rectangle(params[0], params[1], params[2], params[3]);
    }
}
}
