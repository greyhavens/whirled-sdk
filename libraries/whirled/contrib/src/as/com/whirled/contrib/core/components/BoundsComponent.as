package com.whirled.contrib.core.components {
    
public interface BoundsComponent extends LocationComponent
{
    function get width () :Number;
    function set width (val :Number) :void
    
    function get height () :Number;
    function set height (val :Number) :void;
}

}