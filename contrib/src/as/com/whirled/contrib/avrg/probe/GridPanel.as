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
import flash.display.Sprite;
import flash.display.DisplayObject;

/**
 * A panel to display objects in a simple grid with fixed row and column heights and widths.
 */
public class GridPanel extends Sprite
{
    /**
     * Creates a new grid panel.
     * @param widths array of numeric widths, one per grid column
     * @param heights array of numeric heights, one per grid row
     */
    public function GridPanel (widths :Array, heights :Array)
    {
        function sizesToPositions (sizes :Array) :Array {
            var sum :int = 0;
            var pos :Array = [];
            for each (var size :int in sizes) {
                pos.push(sum);
                sum += size;
            }
            pos.push(sum);
            return pos;
        }

        _columns = sizesToPositions(widths);
        _rows = sizesToPositions(heights);
    }

    /**
     * Adds a new cell at the given column and row. The previous contents of the cell are not
     * removed.
     */
    public function addCell (
        column :int, 
        row :int, 
        contents :DisplayObject) :void
    {
        addChild(contents);
        contents.x = _columns[column];
        contents.y = _rows[row];
    }

    /**
     * Gets the size of a cell.
     * @return a point with x = the width of the cell and y = to the height.
     */
    public function getCellSize (column :int, row :int) :Point
    {
        return new Point(
            _columns[column + 1] - _columns[column],
            _rows[row + 1] - _rows[row]);
    }

    /**
     * The number of columns in the grid.
     */
    public function get numColumns () :int
    {
        return _columns.length - 1;
    }

    /**
     * The number of rows in the grid.
     */
    public function get numRows () :int
    {
        return _rows.length - 1;
    }

    protected var _rows :Array = [];
    protected var _columns :Array = [];
}

}
