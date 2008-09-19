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

package com.whirled.contrib.card.graphics {

import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.filters.GlowFilter;

/** Simple text field supporting outlines and vertical positioning.
 *  TODO: this may be useful for other games, move out of card package */
public class Text extends TextField
{
    /** Initialization constant for a small standard text field. */
    public static const SMALL :int = 0;

    /** Initialization constant for a big standard text field. */
    public static const BIG :int = 1;

    /** Initialization constant for a huge standard text field. */
    public static const HUGE :int = 2;

    /** Initialization constant for a small text field in italics. */
    public static const SMALL_ITALIC :int = 3;

    /** Initialization constant for a huge text field in italics with a hard outline. */
    public static const HUGE_HARD_ITALIC :int = 4;

    /** Create a new standard text field of the given size. */
    public function Text(
        size :int = SMALL, 
        foreColor :uint = 0xFFFFFF, 
        backColor :uint = 0x000000)
    {
        _size = size;

        autoSize = TextFieldAutoSize.CENTER;
        
        var params :Array = FORMAT_PARAMS[size] as Array;
        defaultTextFormat = createFormat(
            params[0] as Number, 
            params[1] as Boolean, 
            foreColor);
        selectable = false;
        x = 0;
        y = 0;

        params = OUTLINE_PARAMS[size] as Array;

        filters = [ createGlow(
            params[0] as Number, 
            params[1] as Number, 
            params[2] as Number, 
            backColor) ];
    }

    /** Set the text to right justify. */
    public function rightJustify () :void
    {
        autoSize = TextFieldAutoSize.RIGHT;
    }

    /** Set the text to left justify. */
    public function leftJustify () :void
    {
        autoSize = TextFieldAutoSize.LEFT;
    }

    /** Access the coordinate of the vertical center of the text field. Unlike using an expression
     *  like "y = -text.textHeight / 2", the equivalent "centerY = 0" does not depend on the current 
     *  contents of the text property. */
    public function set centerY (value :Number) :void
    {
        y = value - effectiveTextHeight / 2;
    }

    /** Access the coordinate of the vertical center of the text field. */
    public function get centerY () :Number
    {
        return y + effectiveTextHeight / 2;
    }

    /** Access the coordinate of the bottom of the text field. Unlike using an expression like 
     *  "y = -text.textHeight", the equivalent "bottomY = 0" does not depend on the current 
     *  contents of the text property. */
    public function set bottomY (value :Number) :void
    {
        y = value - effectiveTextHeight;
    }

    /** Access the coordinate of the bottom of the text field. */
    public function get bottomY () :Number
    {
        return y + effectiveTextHeight;
    }

    /** Access the effective text height for use with vertical positioning. */
    public function get effectiveTextHeight () :Number
    {
        return EFFECTIVE_SIZES[_size];
    }

    /** Utility function to truncate a name. */
    public static function truncName (name: String) :String
    {
        if (name.length > MAX_NAME_LENGTH) {
            name = name.substr(0, MAX_NAME_LENGTH) + "...";
        }
        return name;
    }

    protected var _size :int;

    protected static const MAX_NAME_LENGTH :int = 12;

    protected static function createFormat (
        size :int, italic :Boolean, color :uint) :TextFormat
    {
        return new TextFormat("_sans", size, color, false, italic, false, 
            "", "", TextFormatAlign.LEFT, 0, 0, 0, 0);
    }

    protected static function createGlow (
        alpha :Number, size :int, strength :int, color :uint) :GlowFilter
    {
        return new GlowFilter(color, alpha, size, size, strength);
    }

    protected static const FORMAT_PARAMS :Array = [
        [12, false], 
        [14, false],
        [18, false],
        [12, true],
        [24, true]];

    protected static const OUTLINE_PARAMS :Array = [
        [.5, 3, 4], 
        [.7, 3, 4], 
        [.7, 3, 4],
        [.5, 3, 4],
        [.9, 4, 64]]

    protected static const EFFECTIVE_SIZES :Array = [18, 20, 23, 18, 32];
}

}
