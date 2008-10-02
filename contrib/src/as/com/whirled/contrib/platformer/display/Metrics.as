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

/**
 * Various global display metrics.
 */
public class Metrics
{
    public static function init (width :int, height :int, tile :int) :void
    {
        if (_set) {
            throw new Error("Metrics have already been initialized");
        }
        _width = width;
        _height = height;
        _tile = tile;
        _winWidth = Math.ceil(_width / tile);
        _winHeight = Math.ceil(_height / tile);
        _set = true;
    }

    public static function get INITIALIZED () :Boolean
    {
        return (_set);
    }

    public static function get DISPLAY_WIDTH () :int
    {
        return isSet(_width);
    }

    public static function get DISPLAY_HEIGHT () :int
    {
        return isSet(_height);
    }

    public static function get TILE_SIZE () :int
    {
        return isSet(_tile);
    }

    public static function get WINDOW_WIDTH () :int
    {
        return isSet(_winWidth);
    }

    public static function get WINDOW_HEIGHT () :int
    {
        return isSet(_winHeight);
    }

    protected static function isSet (value :int) :int
    {
        if (!_set) {
            throw new Error("Cannot access Metrics before initialization");
        }
        return value;
    }

    protected static var _width :int;
    protected static var _height :int;
    protected static var _tile :int;
    protected static var _winWidth :int;
    protected static var _winHeight :int;
    protected static var _set :Boolean = false;
}
}
