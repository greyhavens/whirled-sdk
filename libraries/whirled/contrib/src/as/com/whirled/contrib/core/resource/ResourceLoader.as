package com.whirled.contrib.core.resource {
    
import flash.events.IEventDispatcher;
    
public interface ResourceLoader extends IEventDispatcher
{
    function get resourceName () :String;
    function get errorString () :String;
    
    function load () :void;
    function unload () :void;
}

}