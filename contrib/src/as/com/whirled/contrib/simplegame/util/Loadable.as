//
// $Id$

package com.whirled.contrib.simplegame.util {

public interface Loadable
{
    function load (onLoaded :Function = null, onLoadErr :Function = null) :void;
    function unload () :void;
    function get isLoaded () :Boolean;
}

}
