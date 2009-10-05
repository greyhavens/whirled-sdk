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

package com.whirled.contrib.platformer.display {

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.filters.ColorMatrixFilter;

import com.threerings.display.ColorMatrix;

public class DisplayUtils
{
    public static function findNode (node :String, disp :DisplayObject) :DisplayObject
    {
        var ret :Array = findNodes([ node ], disp);
        return (ret == null ? null : ret[0]);
    }

    public static function findNodes (nodes :Array, disp :DisplayObject) :Array
    {
        var ret :Array;
        if (disp == null) {
            return ret;
        }
        if (nodes.indexOf(disp.name) != -1) {
            ret = new Array();
            ret.push(disp);
        }
        if (disp is DisplayObjectContainer) {
            var cont :DisplayObjectContainer = disp as DisplayObjectContainer;
            for (var ii :int = 0; ii < cont.numChildren; ii++) {
                var disps :Array = findNodes(nodes, cont.getChildAt(ii));
                if (disps != null) {
                    if (ret == null) {
                        ret = new Array();
                    }
                    ret = ret.concat(disps);
                }
            }
        }
        return ret;
    }

    public static function recolorNodesToColor (
        node :String, disp :DisplayObject, color :int) :ColorMatrixFilter
    {
        var matrix :ColorMatrix = new ColorMatrix();
        matrix.colorize(color);
        var filter :ColorMatrixFilter = matrix.createFilter();
        recolorNodes(node, disp, filter);
        return filter;
    }

    public static function recolorNodes (
        node :String, disp :DisplayObject, filter :ColorMatrixFilter) :void
    {
        if (disp == null) {
            return;
        }
        if (disp.name == node) {
            var filters :Array = disp.filters;
            if (filters == null) {
                if (filter != null) {
                    disp.filters = [filter];
                }
            } else {
                if (filter != null) {
                    filters.push(filter);
                } else {
                    var ii :int = 0;
                    while (ii < filters.length) {
                        if (filters[ii] is ColorMatrixFilter) {
                            filters.splice(ii, 1);
                        } else {
                            ii++;
                        }
                    }
                    if (filters.length == 0) {
                        filters = null;
                    }
                }
                disp.filters = filters;
            }
        }
        if (disp is DisplayObjectContainer) {
            var cont :DisplayObjectContainer = disp as DisplayObjectContainer;
            for (ii = 0; ii < cont.numChildren; ii++) {
                recolorNodes(node, cont.getChildAt(ii), filter);
            }
        }
    }
}
}
