package com.whirled.contrib.core {
    
public class SimObjectRef
{
    public function SimObjectRef ()
    {
    }
    
    public function get object () :SimObject
    {
        return _obj;
    }
    
    public function get isNull () :Boolean
    {
        return (null == _obj);
    }
    
    // managed by ObjectDB
    internal var _obj :SimObject;
    internal var _next :SimObjectRef;
    internal var _prev :SimObjectRef;
}

}