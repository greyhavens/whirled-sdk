package com.whirled.contrib.core {
    
public class AppObjectRef
{
    public function AppObjectRef ()
    {
    }
    
    public function get object () :AppObject
    {
        return _obj;
    }
    
    public function get isNull () :Boolean
    {
        return (null == _obj);
    }
    
    // managed by ObjectDB
    internal var _obj :AppObject;
    internal var _next :AppObjectRef;
    internal var _prev :AppObjectRef;
}

}