// $Id$

package com.threerings.underwhirleddrift.util {

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
