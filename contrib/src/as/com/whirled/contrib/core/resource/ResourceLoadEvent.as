package com.whirled.contrib.core.resource {
    
import flash.events.Event;

public class ResourceLoadEvent extends Event
{
    public static const LOADED :String = "ResourceLoadEvent_Loaded";
    public static const ERROR :String = "ResourceLoadEvent_Error";
    
    public function ResourceLoadEvent (type :String)
    {
        super(type, false, false);
    }
}

}