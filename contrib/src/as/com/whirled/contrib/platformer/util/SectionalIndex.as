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

package com.whirled.contrib.platformer.util {

/**
 * A utility that indexes a first quadrant space into equal sized areas.
 */
public class SectionalIndex
{
    public function SectionalIndex (secWidth :int, secHeight :int, maxWidth :int = 1000)
    {
        _secWidth = secWidth;
        _secHeight = secHeight;
        _maxWidth = maxWidth;
    }

    /**
     * Returns the index for the supplied section.
     */
    public function getSectionIndex (sx :int, sy :int) :int
    {
        return Math.max(sy, 0) * _maxWidth + Math.max(sx, 0);
    }

    /**
     * The display width of a section.
     */
    public function getSectionWidth () :int
    {
        return _secWidth;
    }

    /**
     * The display height of a section.
     */
    public function getSectionHeight () :int
    {
        return _secHeight;
    }

    /**
     * Returns the section x coordinate from a section index.
     */
    public function getSectionX (section :int) :int
    {
        return section % _maxWidth;
    }

    /**
     * Returns the section y coordinate from a section index.
     */
    public function getSectionY (section :int) :int
    {
        return Math.floor(section / _maxWidth);
    }

    /**
     * Converts a global x value to the local x value in a section.
     */
    public function getLocalX (sx :int) :int
    {
        return sx % _secWidth;
    }

    /**
     * Converts a global y value to the local y value in a section.
     */
    public function getLocalY (sy :int) :int
    {
        return sy % _secHeight;
    }

    /**
     * Returns true if this x value is inside the area being indexed.
     */
    public function validX (x :int) :Boolean
    {
        return x >= 0 && x < _maxWidth;
    }

    /**
     * Returns true if this y value is inside the area being indexed.
     */
    public function validY (y :int) :Boolean
    {
        return y >= 0;
    }

    /**
     * Returns the section index for the supplied global coordinates.
     */
    public function getSectionFromTile (tx :int, ty :int) :int
    {
        return getSectionIndex(getSectionXFromTile(tx), getSectionYFromTile(ty));
    }

    /**
     * Returns the x value of the section this global x value resides in.
     */
    public function getSectionXFromTile (tx :int) :int
    {
        return Math.floor(tx / _secWidth);
    }

    /**
     * Returns the y value of the section this global y value resides in.
     */
    public function getSectionYFromTile (ty :int) :int
    {
        return Math.floor(ty / _secHeight);
    }

    protected var _secWidth :int;
    protected var _secHeight :int;
    protected var _maxWidth :int;
}
}
