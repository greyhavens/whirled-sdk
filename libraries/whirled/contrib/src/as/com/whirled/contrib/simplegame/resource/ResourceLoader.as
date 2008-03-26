package com.whirled.contrib.simplegame.resource {

import flash.events.IEventDispatcher;

public interface ResourceLoader extends IEventDispatcher
{
    function get resourceName () :String;

    function load () :void;
    function unload () :void;
}

}
