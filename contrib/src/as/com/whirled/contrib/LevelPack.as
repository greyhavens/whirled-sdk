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

package com.whirled.contrib {

/** 
 * Represents the data from WhirledGameControl.getLevelPacks() in a type-safe manner.
 */
public class LevelPack
{
    /** 
     * Typically, LevelPacks are only created by the LevelPacks class, by fetching the data from 
     * WhirledGameControl.getLevelPacks().
     */
    public function LevelPack (ident :String, name :String, mediaURL :String, premium :Boolean) 
    {
        _ident = ident;
        _name = name;
        _mediaURL = mediaURL;
        _premium = premium;
    }

    public function get ident () :String
    {
        return _ident;
    }

    public function get name () :String
    {
        return _name;
    }

    public function get mediaURL () :String
    {
        return _mediaURL;
    }
    
    public function get premium () :Boolean
    {
        return _premium;
    }

    protected var _ident :String;
    protected var _name :String;
    protected var _mediaURL :String;
    protected var _premium :Boolean;
}
}
