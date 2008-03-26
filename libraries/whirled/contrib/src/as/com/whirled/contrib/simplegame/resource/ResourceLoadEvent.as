package com.whirled.contrib.simplegame.resource {

import flash.events.Event;

public class ResourceLoadEvent extends Event
{
    public static const LOADED :String = "Loaded";
    public static const ERROR :String = "Error";

    public var data :Object;

    public function ResourceLoadEvent (type :String, data :Object = null)
    {
        super(type, false, false);

        this.data = data;
    }
}

}
