package com.whirled.contrib.core {
    
import flash.events.Event;

public class ResourceLoadEvent extends Event
{
    public static const RESOURCES_LOADED :String = "ResourceLoadEvent_Loaded";
    public static const ERROR :String = "ResourceLoadEvent_Error";
    
    public function ResourceLoadEvent (type :String, rsrcMgr :ResourceManager)
    {
        super(type, false, false);
        _rsrcMgr = rsrcMgr;
    }
    
    public function get resourceManager () :ResourceManager
    {
        return _rsrcMgr;
    }
    
    protected var _rsrcMgr :ResourceManager;
}

}